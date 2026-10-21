#!/usr/bin/env python3
"""中島汽船の時刻表を取得し docs/ferry/kutsuna.json を生成する。

取得元は HTTP の時刻表ページ1枚だけ。表の列は取得した HTML の構造に合わせている。

- 東線（フェリー・高速船）: 1つの表の左が上り、右が下り
- 西線（フェリー）: 上りと下りが別の表
- 西線（高速船）: 見出しに上り下りが無く、高浜を出て高浜へ戻る1行

「→」「―」と空欄はその港に寄らない。時刻でない文言（当面の間運休など）は
時刻にせず、その便の note に残す。運休だけで時刻が無い便は departure / arrival を
null にする（時刻を作らない）。
"""
from __future__ import annotations

import hashlib
import json
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Sequence, Tuple

from bs4 import BeautifulSoup
from bs4.element import Tag

ROOT = Path(__file__).resolve().parents[1]
OUTPUT_PATH = ROOT / "docs" / "ferry" / "kutsuna.json"
SOURCE_URL = "http://www.nakajimakisen.co.jp/contents/time-table.html"
SOURCE_NAME = "中島汽船株式会社"
USER_AGENT = "IslandBase-timetable-bot (+https://oooopq.github.io/island-base/)"
TIMEOUT_SECONDS = 20
MAX_RETRIES = 2
RETRY_INTERVAL_SECONDS = 5
MAX_JSON_BYTES = 256 * 1024
SCHEMA_VERSION = 1

ISLAND_IDS: Tuple[str, ...] = (
    "nakajima",
    "muzukijima",
    "nogutsunajima",
    "nuwajima",
    "tsuwajishima",
    "futagamijima",
    "tsurushima",
)

# ページの港名（「港」なし）→ KutsunaIslandProfiles の島ID。
# 高浜・三津浜・松山観光港は島側の港一覧に無い松山側。
PORT_TO_ISLAND: Dict[str, str] = {
    "大浦": "nakajima",
    "西中": "nakajima",
    "神浦": "nakajima",
    "睦月": "muzukijima",
    "野忽那": "nogutsunajima",
    "上怒和": "nuwajima",
    "元怒和": "nuwajima",
    "津和地": "tsuwajishima",
    "二神": "futagamijima",
    "釣島": "tsurushima",
}
MAINLAND_PORTS = frozenset({"高浜", "三津浜", "松山観光港"})
KNOWN_PORTS = frozenset(PORT_TO_ISLAND) | MAINLAND_PORTS

LINE_SLUG = {"東線": "east", "西線": "west"}
SECTION_PATTERN = re.compile(r"(東線|西線)（(フェリー|高速船)）")
VALID_FROM_PATTERN = re.compile(
    r"(\d{4})年(\d{1,2})月(\d{1,2})日(?:\([^)]*\))?からの時刻表"
)
TIME_TEXT_PATTERN = re.compile(r"^(\d{1,2}):(\d{2})$")
HHMM_PATTERN = re.compile(r"^(?:[01]\d|2[0-3]):[0-5]\d$")
FETCHED_AT_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}Z$")
VALID_FROM_VALUE_PATTERN = re.compile(r"^\d{4}-\d{2}-\d{2}$")
# 実ページは寄港しない印に「→」を使う。仕様の空欄・「―」も同じ扱い。
SKIP_TOKENS = frozenset({"", "→", "⇒", "➡", "―", "—", "–", "-", "－", "ー", "−"})

IslandTrip = Tuple[str, Dict[str, Any]]


class NonHttpRedirect(Exception):
    """時刻表 URL を HTTPS など別スキームへ取りに行かない。"""


@dataclass(frozen=True)
class PortStop:
    port: str
    kind: str  # time / skip / note
    time: Optional[str] = None
    note: Optional[str] = None


@dataclass(frozen=True)
class Sailing:
    line: str
    kind: str
    direction: str  # up / down / loop
    stops: Tuple[PortStop, ...]


class _HttpOnlyRedirectHandler(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):  # type: ignore[override]
        if urllib.parse.urlparse(newurl).scheme != "http":
            raise NonHttpRedirect(f"HTTP以外への転送は使いません: {newurl}")
        return super().redirect_request(req, fp, code, msg, headers, newurl)


def fetch_timetable_html(
    url: str = SOURCE_URL,
    opener: Optional[urllib.request.OpenerDirector] = None,
    sleep=time.sleep,
) -> str:
    """時刻表ページを1URLだけ取得する。失敗時は5秒間隔で最大2回リトライする。"""
    if urllib.parse.urlparse(url).scheme != "http":
        raise ValueError(f"時刻表の取得は HTTP のみです: {url}")
    if opener is None:
        opener = urllib.request.build_opener(_HttpOnlyRedirectHandler)
    last_error: Optional[BaseException] = None
    attempts = MAX_RETRIES + 1
    for attempt in range(1, attempts + 1):
        request = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        try:
            with opener.open(request, timeout=TIMEOUT_SECONDS) as response:
                raw = response.read()
                charset = response.headers.get_content_charset() or "utf-8"
            return raw.decode(charset)
        except NonHttpRedirect:
            raise
        except (urllib.error.URLError, TimeoutError, UnicodeError) as error:
            last_error = error
            if attempt <= MAX_RETRIES:
                print(
                    f"再試行 {attempt}/{MAX_RETRIES} — {RETRY_INTERVAL_SECONDS}s 後: {error}",
                    file=sys.stderr,
                )
                sleep(RETRY_INTERVAL_SECONDS)
    raise RuntimeError(f"時刻表の取得に失敗しました: {url}") from last_error


def cell_text(cell: Tag) -> str:
    text = cell.get_text(" ", strip=True).replace("\u00a0", " ").replace("：", ":")
    return re.sub(r"\s+", " ", text).strip()


def port_label(cell: Tag) -> str:
    """ふりがな（span.s_text*）を除いた港名。ページは「大浦」のように「港」を付けない。"""
    fragments: List[str] = []
    br = cell.find("br")
    nodes: Iterable[Any]
    if br is not None:
        nodes = br.next_siblings
    else:
        nodes = cell.children
    for node in nodes:
        if getattr(node, "name", None) == "span":
            classes = node.get("class") or []
            if any(str(class_name).startswith("s_text") for class_name in classes):
                continue
        text = node.get_text("", strip=True) if hasattr(node, "get_text") else str(node)
        fragments.append(text)
    label = "".join(fragments).replace("\u00a0", "")
    return re.sub(r"\s+", "", label)


def classify_cell(text: str) -> Tuple[str, Optional[str]]:
    """セルを time / skip / note に分ける。範囲外の時刻はページ改変として失敗する。"""
    normalized = text.replace("：", ":").strip()
    compact = re.sub(r"\s+", "", normalized)
    if compact in SKIP_TOKENS:
        return "skip", None
    match = TIME_TEXT_PATTERN.match(compact)
    if match:
        hour = int(match.group(1))
        minute = int(match.group(2))
        if not (0 <= hour <= 23 and 0 <= minute <= 59):
            raise ValueError(f"時刻の範囲が不正です: {compact}")
        return "time", f"{hour:02d}:{minute:02d}"
    if not normalized:
        return "skip", None
    return "note", normalized


def extract_valid_from(soup: BeautifulSoup) -> Optional[str]:
    for heading in soup.find_all("h3"):
        match = VALID_FROM_PATTERN.search(heading.get_text(" ", strip=True))
        if not match:
            continue
        year, month, day = (int(match.group(index)) for index in range(1, 4))
        try:
            datetime(year, month, day)
        except ValueError as error:
            raise ValueError(f"運航開始日が不正です: {match.group(0)}") from error
        return f"{year:04d}-{month:02d}-{day:02d}"
    return None


def _expanded_cells(row: Tag) -> List[Tuple[Tag, bool]]:
    expanded: List[Tuple[Tag, bool]] = []
    for cell in row.find_all(["td", "th"], recursive=False):
        if cell.name is None:
            continue
        try:
            colspan = int(cell.get("colspan") or 1)
            rowspan = int(cell.get("rowspan") or 1)
        except ValueError as error:
            raise ValueError("時刻表の colspan / rowspan が数値ではありません") from error
        if rowspan != 1:
            raise ValueError("rowspan のある時刻表には対応していません")
        if colspan < 1:
            raise ValueError("colspan が不正です")
        for offset in range(colspan):
            expanded.append((cell, offset == 0))
    return expanded


def _is_label_cell(cell: Tag) -> bool:
    classes = cell.get("class") or []
    if "anblue2" in classes:
        return True
    return port_label(cell).startswith("便")


def iter_sections(root: Tag) -> List[Dict[str, Any]]:
    sections: List[Dict[str, Any]] = []
    current: Optional[Dict[str, Any]] = None
    for child in root.find_all(recursive=False):
        if child.name == "dl" and "label" in (child.get("class") or []):
            term = child.find("dt")
            text = term.get_text(" ", strip=True) if term else ""
            match = SECTION_PATTERN.search(text)
            if not match:
                continue
            current = {
                "line": match.group(1),
                "kind": "ferry" if match.group(2) == "フェリー" else "highspeed",
                "tables": [],
            }
            sections.append(current)
        elif child.name == "table" and current is not None:
            if "便別" not in child.get_text(" ", strip=True):
                continue
            current["tables"].append(child)
    return sections


def parse_table(table: Tag, line: str, kind: str) -> List[Sailing]:
    rows = table.find_all("tr")
    if len(rows) < 3:
        raise ValueError(f"{line} {kind}: 時刻表の行が足りません")
    header_cells = _expanded_cells(rows[0])
    port_cells = _expanded_cells(rows[1])
    if len(header_cells) != len(port_cells):
        raise ValueError(f"{line} {kind}: 見出しの列数が港の行と一致しません")
    if not any(_is_label_cell(cell) for cell, _origin in port_cells):
        raise ValueError(f"{line} {kind}: 便の列が見つかりません")

    groups: List[Dict[str, Any]] = []
    current: Optional[Dict[str, Any]] = None
    for index, (cell, _origin) in enumerate(port_cells):
        if _is_label_cell(cell):
            current = {"columns": [], "direction": None}
            groups.append(current)
            continue
        if current is None:
            raise ValueError(f"{line} {kind}: 港の列が便の列より前にあります")
        label = port_label(cell)
        if label not in KNOWN_PORTS:
            raise ValueError(f"未知の港です: {label or '(空)'}")
        header_text = cell_text(header_cells[index][0])
        if "上り" in header_text:
            direction = "up"
        elif "下り" in header_text:
            direction = "down"
        else:
            direction = None
        if current["direction"] is None:
            current["direction"] = direction
        elif direction is not None and current["direction"] != direction:
            raise ValueError(f"{line} {kind}: 1つの便に上りと下りが混在しています")
        current["columns"].append((index, label))

    sailings: List[Sailing] = []
    for row in rows[2:]:
        data_cells = _expanded_cells(row)
        if len(data_cells) != len(port_cells):
            raise ValueError(f"{line} {kind}: 便の列数が港の行と一致しません")
        for group in groups:
            if not group["columns"]:
                continue
            direction = group["direction"] or "loop"
            stops: List[PortStop] = []
            for index, label in group["columns"]:
                cell, is_origin = data_cells[index]
                kind_name, value = classify_cell(cell_text(cell))
                if not is_origin and kind_name == "time":
                    raise ValueError(f"{line} {kind}: 時刻セルが複数の港にまたがっています")
                if kind_name == "time":
                    stops.append(PortStop(label, "time", time=value))
                elif kind_name == "note":
                    stops.append(PortStop(label, "note", note=value))
                else:
                    stops.append(PortStop(label, "skip"))
            sailings.append(Sailing(line, kind, direction, tuple(stops)))
    if not sailings:
        raise ValueError(f"{line} {kind}: 便の行がありません")
    return sailings


def _note_text(stops: Sequence[PortStop]) -> Optional[str]:
    notes: List[str] = []
    for stop in stops:
        if stop.kind == "note" and stop.note and stop.note not in notes:
            notes.append(stop.note)
    if not notes:
        return None
    return " / ".join(notes)


def _split_directions(sailing: Sailing) -> List[Tuple[str, Tuple[PortStop, ...]]]:
    if sailing.direction in ("up", "down"):
        return [(sailing.direction, sailing.stops)]
    names = [stop.port for stop in sailing.stops]
    first_repeat: Optional[int] = None
    seen = set()
    for index, name in enumerate(names):
        if name in seen:
            first_repeat = index
            break
        seen.add(name)
    if first_repeat is None or first_repeat == 0:
        raise ValueError(f"{sailing.line} {sailing.kind}: 往復便の折り返しを判別できません")
    turn = first_repeat - 1
    # 高浜→島々が下り、折り返しから高浜へ戻る方が上り。
    return [
        ("down", sailing.stops[: turn + 1]),
        ("up", sailing.stops[turn:]),
    ]


def _trip(
    origin: str,
    destination: str,
    departure: Optional[str],
    arrival: Optional[str],
    note: Optional[str],
) -> Dict[str, Any]:
    return {
        "from": origin,
        "to": destination,
        "departure": departure,
        "arrival": arrival,
        "note": note,
    }


def _trips_for_direction(direction: str, stops: Sequence[PortStop]) -> List[IslandTrip]:
    note = _note_text(stops)
    timed = [stop for stop in stops if stop.kind == "time"]
    if not timed:
        if note is None:
            return []
        mainland = [stop.port for stop in stops if stop.port in MAINLAND_PORTS]
        island_ports: List[Tuple[str, str]] = []
        seen = set()
        for stop in stops:
            island = PORT_TO_ISLAND.get(stop.port)
            if island and island not in seen:
                seen.add(island)
                island_ports.append((island, stop.port))
        if not mainland or not island_ports:
            raise ValueError("運休便の発着港を判別できません")
        if direction == "up":
            terminus = mainland[-1]
            return [
                (island, _trip(port, terminus, None, None, note))
                for island, port in island_ports
            ]
        origin = mainland[0]
        return [
            (island, _trip(origin, port, None, None, note))
            for island, port in island_ports
        ]

    mainland_timed = [stop for stop in timed if stop.port in MAINLAND_PORTS]
    if not mainland_timed:
        raise ValueError("本土側の寄港時刻が無い便は解釈できません")
    results: List[IslandTrip] = []
    if direction == "up":
        terminus = mainland_timed[-1]
        terminus_at = timed.index(terminus)
        for stop in timed[terminus_at + 1 :]:
            if stop.port in PORT_TO_ISLAND:
                raise ValueError(f"上りで本土側の後に島の港があります: {stop.port}")
        for stop in timed[:terminus_at]:
            island = PORT_TO_ISLAND.get(stop.port)
            if not island:
                continue
            results.append((island, _trip(stop.port, terminus.port, stop.time, terminus.time, note)))
        return results

    origin = mainland_timed[0]
    origin_at = timed.index(origin)
    for stop in timed[:origin_at]:
        if stop.port in PORT_TO_ISLAND:
            raise ValueError(f"下りで本土側の前に島の港があります: {stop.port}")
    for stop in timed[origin_at + 1 :]:
        island = PORT_TO_ISLAND.get(stop.port)
        if not island:
            continue
        results.append((island, _trip(origin.port, stop.port, origin.time, stop.time, note)))
    return results


def sailings_to_islands(sailings: Sequence[Sailing]) -> Dict[str, List[Dict[str, Any]]]:
    buckets: Dict[Tuple[str, str, str], List[Dict[str, Any]]] = {}
    order: List[Tuple[str, str, str]] = []
    for sailing in sailings:
        for direction, stops in _split_directions(sailing):
            for island, trip in _trips_for_direction(direction, stops):
                key = (island, sailing.line, sailing.kind)
                if key not in buckets:
                    buckets[key] = []
                    order.append(key)
                buckets[key].append(trip)

    islands: Dict[str, List[Dict[str, Any]]] = {}
    for island in ISLAND_IDS:
        schedules: List[Dict[str, Any]] = []
        for key in order:
            if key[0] != island:
                continue
            _island, line, kind = key
            schedules.append(
                {
                    "id": f"{island}-kisen-{kind}-{LINE_SLUG[line]}",
                    "line": line,
                    "kind": kind,
                    "trips": buckets[key],
                }
            )
        if schedules:
            islands[island] = schedules
    return islands


def parse_timetable(html: str) -> Dict[str, Any]:
    soup = BeautifulSoup(html, "html.parser")
    valid_from = extract_valid_from(soup)
    root = soup.select_one("#right-column")
    if root is None:
        raise ValueError("時刻表の領域が見つかりません")
    sections = iter_sections(root)
    if not sections:
        raise ValueError("時刻表の表が見つかりません")
    for section in sections:
        label = "フェリー" if section["kind"] == "ferry" else "高速船"
        if not section["tables"]:
            raise ValueError(f"{section['line']}（{label}）の表が見つかりません")
    sailings: List[Sailing] = []
    for section in sections:
        for table in section["tables"]:
            sailings.extend(parse_table(table, section["line"], section["kind"]))
    if not sailings:
        raise ValueError("時刻表の便を解釈できません")
    return {"validFrom": valid_from, "islands": sailings_to_islands(sailings)}


def content_hash(valid_from: Optional[str], islands: Dict[str, Any]) -> str:
    payload = {"validFrom": valid_from, "islands": islands}
    encoded = json.dumps(payload, ensure_ascii=False, sort_keys=True, separators=(",", ":")).encode("utf-8")
    return hashlib.sha256(encoded).hexdigest()


def dump_document(document: Dict[str, Any]) -> str:
    return json.dumps(document, ensure_ascii=False, indent=2) + "\n"


def count_trips(document: Dict[str, Any]) -> int:
    islands = document.get("islands")
    if not isinstance(islands, dict):
        raise ValueError("islands がオブジェクトではありません")
    total = 0
    for island_id, schedules in islands.items():
        if not isinstance(schedules, list):
            raise ValueError(f"{island_id}: ダイヤが配列ではありません")
        for schedule in schedules:
            trips = schedule.get("trips") if isinstance(schedule, dict) else None
            if not isinstance(trips, list):
                raise ValueError(f"{island_id}: trips が配列ではありません")
            total += len(trips)
    return total


def _require_time(value: Any, context: str, *, allow_null: bool) -> None:
    if value is None:
        if allow_null:
            return
        raise ValueError(f"{context}: 時刻がありません")
    if not isinstance(value, str) or not HHMM_PATTERN.match(value):
        raise ValueError(f"{context}: 時刻が HH:MM ではありません ({value!r})")


def validate_document(document: Dict[str, Any], previous: Optional[Dict[str, Any]]) -> None:
    if document.get("schemaVersion") != SCHEMA_VERSION:
        raise ValueError("schemaVersion が 1 ではありません")
    source = document.get("source")
    if not isinstance(source, dict) or source.get("name") != SOURCE_NAME or source.get("url") != SOURCE_URL:
        raise ValueError("source が中島汽船の時刻表ではありません")
    fetched_at = document.get("fetchedAt")
    if not isinstance(fetched_at, str) or not FETCHED_AT_PATTERN.match(fetched_at):
        raise ValueError("fetchedAt が UTC の ISO8601 ではありません")
    valid_from = document.get("validFrom")
    if valid_from is not None and (
        not isinstance(valid_from, str) or not VALID_FROM_VALUE_PATTERN.match(valid_from)
    ):
        raise ValueError("validFrom が YYYY-MM-DD ではありません")
    islands = document.get("islands")
    if not isinstance(islands, dict):
        raise ValueError("islands がオブジェクトではありません")
    if set(islands) != set(ISLAND_IDS):
        missing = [island_id for island_id in ISLAND_IDS if island_id not in islands]
        raise ValueError(f"7島そろっていません: {', '.join(missing) or '未知の島があります'}")
    expected_hash = content_hash(valid_from, islands)
    if document.get("contentHash") != expected_hash:
        raise ValueError("contentHash がパース結果と一致しません")

    for island_id in ISLAND_IDS:
        schedules = islands[island_id]
        if not isinstance(schedules, list) or not schedules:
            raise ValueError(f"{island_id}: ダイヤがありません")
        trip_total = 0
        for schedule in schedules:
            if not isinstance(schedule, dict):
                raise ValueError(f"{island_id}: ダイヤの形式が不正です")
            if schedule.get("line") not in LINE_SLUG:
                raise ValueError(f"{island_id}: line が不正です")
            if schedule.get("kind") not in ("ferry", "highspeed"):
                raise ValueError(f"{island_id}: kind が不正です")
            if not isinstance(schedule.get("id"), str) or not schedule["id"]:
                raise ValueError(f"{island_id}: id がありません")
            trips = schedule.get("trips")
            if not isinstance(trips, list):
                raise ValueError(f"{island_id}: trips が配列ではありません")
            trip_total += len(trips)
            for trip in trips:
                if not isinstance(trip, dict):
                    raise ValueError(f"{island_id}: 便の形式が不正です")
                origin = trip.get("from")
                destination = trip.get("to")
                if not isinstance(origin, str) or not origin or not isinstance(destination, str) or not destination:
                    raise ValueError(f"{island_id}: 発着港がありません")
                note = trip.get("note")
                if note is not None and (not isinstance(note, str) or not note.strip()):
                    raise ValueError(f"{island_id}: note が空です")
                allow_null_departure = isinstance(note, str) and bool(note.strip())
                _require_time(
                    trip.get("departure"),
                    f"{island_id} departure",
                    allow_null=allow_null_departure,
                )
                _require_time(trip.get("arrival"), f"{island_id} arrival", allow_null=True)
        if not 1 <= trip_total <= 100:
            raise ValueError(f"{island_id}: 便数が範囲外です ({trip_total})")

    encoded = dump_document(document).encode("utf-8")
    if len(encoded) > MAX_JSON_BYTES:
        raise ValueError(f"JSON が 256KB を超えています ({len(encoded)} bytes)")

    if previous is not None:
        previous_total = count_trips(previous)
        current_total = count_trips(document)
        if previous_total > 0 and current_total * 2 <= previous_total:
            raise ValueError(
                f"便数が前回の50%以下です（前回 {previous_total} / 今回 {current_total}）"
            )


def generate_document(html: str, fetched_at: str) -> Dict[str, Any]:
    parsed = parse_timetable(html)
    islands = parsed["islands"]
    valid_from = parsed["validFrom"]
    return {
        "schemaVersion": SCHEMA_VERSION,
        "source": {"name": SOURCE_NAME, "url": SOURCE_URL},
        "fetchedAt": fetched_at,
        "validFrom": valid_from,
        "contentHash": content_hash(valid_from, islands),
        "islands": islands,
    }


def reuse_previous_if_unchanged(
    document: Dict[str, Any],
    previous: Optional[Dict[str, Any]],
) -> Dict[str, Any]:
    """contentHash が前回と同じなら、fetchedAt 以外は前回の JSON をそのまま使う。"""
    if previous is None or previous.get("contentHash") != document.get("contentHash"):
        return document
    updated = dict(previous)
    updated["fetchedAt"] = document["fetchedAt"]
    return updated


def load_previous(path: Path) -> Optional[Dict[str, Any]]:
    if not path.exists():
        return None
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError) as error:
        raise ValueError(f"既存の {path.name} を読めないため更新しません") from error
    if not isinstance(data, dict):
        raise ValueError(f"既存の {path.name} がオブジェクトではないため更新しません")
    return data


def write_atomic(path: Path, document: Dict[str, Any]) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    try:
        temporary.write_text(dump_document(document), encoding="utf-8")
        temporary.replace(path)
    except Exception:
        temporary.unlink(missing_ok=True)
        raise


def publish(document: Dict[str, Any], previous: Optional[Dict[str, Any]], path: Path) -> None:
    validate_document(document, previous)
    write_atomic(path, document)


def utc_now_stamp() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def main() -> int:
    try:
        html = fetch_timetable_html()
        previous = load_previous(OUTPUT_PATH)
        document = reuse_previous_if_unchanged(generate_document(html, utc_now_stamp()), previous)
        publish(document, previous, OUTPUT_PATH)
    except Exception as error:
        print(f"時刻表の取得または検証に失敗したため kutsuna.json は更新しません: {error}", file=sys.stderr)
        return 1
    print(f"wrote {OUTPUT_PATH} ({count_trips(document)} trips)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
