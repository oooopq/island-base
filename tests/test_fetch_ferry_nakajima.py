import json
from pathlib import Path

import pytest

from scripts.fetch_ferry_nakajima import (
    ISLAND_IDS,
    KNOWN_PORTS,
    SOURCE_URL,
    USER_AGENT,
    NonHttpRedirect,
    classify_cell,
    count_trips,
    fetch_timetable_html,
    content_hash,
    generate_document,
    main,
    parse_timetable,
    reuse_previous_if_unchanged,
    validate_document,
)

FIXTURE = Path(__file__).resolve().parents[1] / "tests" / "fixtures" / "nakajima_timetable.html"
FETCHED_AT = "2026-10-21T01:00:00Z"
SUSPENSION = "2025年2月1日から当面の間運休"

EXPECTED_TRIP_COUNTS = {
    "nakajima": 38,
    "muzukijima": 17,
    "nogutsunajima": 15,
    "nuwajima": 18,
    "tsuwajishima": 11,
    "futagamijima": 14,
    "tsurushima": 4,
}


def _fixture_html() -> str:
    return FIXTURE.read_text(encoding="utf-8")


def _document(html: str | None = None, fetched_at: str = FETCHED_AT):
    return generate_document(_fixture_html() if html is None else html, fetched_at)


def _trip(schedule_trips, **expected):
    for trip in schedule_trips:
        if all(trip[key] == value for key, value in expected.items()):
            return trip
    raise AssertionError(f"便がありません: {expected}")


def _schedules(document, island_id):
    return {schedule["id"]: schedule for schedule in document["islands"][island_id]}


def _timetable_html(rows: str, heading: str = "東線（フェリー）") -> str:
    return f"""
    <html><body>
      <h3>2026年3月4日からの時刻表</h3>
      <div id="right-column">
        <dl class="label"><dt>{heading}</dt></dl>
        <table>
          <tr><th>便別</th><th colspan="4">上り（松山方面行）</th></tr>
          <tr>
            <td class="anblue2">便 \\ 港</td>
            <td><span class="s_text02">おおうら</span><br />大浦</td>
            <td>野忽那</td>
            <td>睦月</td>
            <td>三津浜</td>
          </tr>
          {rows}
        </table>
      </div>
    </body></html>
    """


def test_fixture_parses_every_island_and_representative_trips():
    document = _document()
    validate_document(document, None)

    assert document["validFrom"] == "2025-02-01"
    assert document["source"] == {"name": "中島汽船株式会社", "url": SOURCE_URL}
    assert document["fetchedAt"] == FETCHED_AT
    assert set(document["islands"]) == set(ISLAND_IDS)

    for island_id, expected in EXPECTED_TRIP_COUNTS.items():
        actual = sum(len(schedule["trips"]) for schedule in document["islands"][island_id])
        assert actual == expected

    nakajima = _schedules(document, "nakajima")
    assert list(nakajima) == [
        "nakajima-kisen-ferry-east",
        "nakajima-kisen-highspeed-east",
        "nakajima-kisen-ferry-west",
        "nakajima-kisen-highspeed-west",
    ]
    # 東線フェリー上り1便。野忽那・高浜は「→」なので寄港にしない。到着は三津浜。
    assert nakajima["nakajima-kisen-ferry-east"]["trips"][0] == {
        "from": "大浦",
        "to": "三津浜",
        "departure": "05:40",
        "arrival": "06:40",
        "note": None,
    }
    assert _trip(
        nakajima["nakajima-kisen-ferry-west"]["trips"],
        **{"from": "西中", "to": "三津浜", "departure": "06:06", "arrival": "08:50", "note": None},
    )
    assert _trip(
        nakajima["nakajima-kisen-highspeed-west"]["trips"],
        **{"from": "高浜", "to": "神浦", "departure": "07:40", "arrival": "08:06", "note": None},
    )
    assert _trip(
        nakajima["nakajima-kisen-highspeed-east"]["trips"],
        **{"from": "高浜", "to": "大浦", "departure": None, "arrival": None, "note": SUSPENSION},
    )

    muzukijima = _schedules(document, "muzukijima")
    assert _trip(
        muzukijima["muzukijima-kisen-ferry-east"]["trips"],
        **{"from": "睦月", "to": "三津浜", "departure": "05:59", "arrival": "06:40", "note": None},
    )
    # 東線高速船下り5便の睦月は「→」。19:25発の便は作らない。
    assert not any(
        trip["departure"] == "19:25" for trip in muzukijima["muzukijima-kisen-highspeed-east"]["trips"]
    )

    nogutsuna = _schedules(document, "nogutsunajima")
    assert _trip(
        nogutsuna["nogutsunajima-kisen-ferry-east"]["trips"],
        **{"from": "野忽那", "to": "三津浜", "departure": "08:56", "arrival": "09:57", "note": None},
    )
    assert not any(trip["departure"] == "05:40" for trip in nogutsuna["nogutsunajima-kisen-ferry-east"]["trips"])

    nuwajima = _schedules(document, "nuwajima")
    assert _trip(
        nuwajima["nuwajima-kisen-ferry-west"]["trips"],
        **{"from": "上怒和", "to": "三津浜", "departure": "06:23", "arrival": "08:50", "note": None},
    )
    tsuwaji = _schedules(document, "tsuwajishima")
    assert _trip(
        tsuwaji["tsuwajishima-kisen-highspeed-west"]["trips"],
        **{"from": "津和地", "to": "高浜", "departure": "12:34", "arrival": "13:36", "note": None},
    )
    futagami = _schedules(document, "futagamijima")
    assert _trip(
        futagami["futagamijima-kisen-highspeed-west"]["trips"],
        **{"from": "二神", "to": "高浜", "departure": "08:56", "arrival": "09:36", "note": None},
    )
    tsurushima = _schedules(document, "tsurushima")
    assert list(tsurushima) == ["tsurushima-kisen-ferry-west"]
    assert tsurushima["tsurushima-kisen-ferry-west"]["trips"] == [
        {"from": "釣島", "to": "三津浜", "departure": "08:08", "arrival": "08:50", "note": None},
        {"from": "釣島", "to": "三津浜", "departure": "16:02", "arrival": "16:25", "note": None},
        {"from": "三津浜", "to": "釣島", "departure": "09:10", "arrival": "09:35", "note": None},
        {"from": "三津浜", "to": "釣島", "departure": "16:40", "arrival": "17:20", "note": None},
    ]


def test_fixture_times_ports_and_suspension_notes_stay_in_their_fields():
    document = _document()
    encoded = json.dumps(document, ensure_ascii=False)
    assert "Copyright" not in encoded
    assert ".jpg" not in encoded
    assert len(encoded.encode("utf-8")) <= 256 * 1024

    for schedules in document["islands"].values():
        for schedule in schedules:
            assert schedule["line"] in ("東線", "西線")
            assert schedule["kind"] in ("ferry", "highspeed")
            for trip in schedule["trips"]:
                assert trip["from"] in KNOWN_PORTS
                assert trip["to"] in KNOWN_PORTS
                for key in ("departure", "arrival"):
                    value = trip[key]
                    if value is None:
                        assert trip["note"]
                        continue
                    assert isinstance(value, str)
                    assert "運休" not in value
                if trip["note"] is not None:
                    assert "運休" in trip["note"]
                    assert trip["departure"] is None
                    assert trip["arrival"] is None


def test_skip_cells_and_suspension_cells():
    assert classify_cell("→") == ("skip", None)
    assert classify_cell("―") == ("skip", None)
    assert classify_cell("") == ("skip", None)
    assert classify_cell("  ") == ("skip", None)
    assert classify_cell("8:05") == ("time", "08:05")
    assert classify_cell("当面の間運休")[0] == "note"

    parsed = parse_timetable(
        _timetable_html(
            """
            <tr><td>1</td><td>8:05</td><td>―</td><td></td><td>9:10</td></tr>
            <tr><td>2</td><td>10:00</td><td>当面の間運休</td><td>→</td><td>11:00</td></tr>
            <tr><td>3</td><td colspan="4">2026年3月4日から当面の間運休</td></tr>
            """
        )
    )
    nakajima = parsed["islands"]["nakajima"][0]["trips"]
    assert nakajima[0] == {
        "from": "大浦",
        "to": "三津浜",
        "departure": "08:05",
        "arrival": "09:10",
        "note": None,
    }
    assert nakajima[1] == {
        "from": "大浦",
        "to": "三津浜",
        "departure": "10:00",
        "arrival": "11:00",
        "note": "当面の間運休",
    }
    assert nakajima[2]["departure"] is None
    assert nakajima[2]["note"] == "2026年3月4日から当面の間運休"
    assert "nogutsunajima" not in {
        island
        for island, schedules in parsed["islands"].items()
        for schedule in schedules
        for trip in schedule["trips"]
        if trip["departure"] == "08:05"
    }
    nogutsuna_trips = parsed["islands"]["nogutsunajima"][0]["trips"]
    assert nogutsuna_trips == [
        {
            "from": "野忽那",
            "to": "三津浜",
            "departure": None,
            "arrival": None,
            "note": "2026年3月4日から当面の間運休",
        }
    ]
    assert parsed["validFrom"] == "2026-03-04"


def test_broken_html_without_a_table_fails():
    with pytest.raises(ValueError, match="時刻表の表が見つかりません"):
        parse_timetable("<html><body><div id='right-column'><p>なし</p></div></body></html>")


def test_out_of_range_time_fails():
    with pytest.raises(ValueError, match="時刻の範囲が不正"):
        parse_timetable(_timetable_html("<tr><td>1</td><td>8:00</td><td>→</td><td>→</td><td>25:00</td></tr>"))


def test_same_content_updates_only_fetched_at():
    first = _document(fetched_at="2026-10-21T01:00:00Z")
    second = _document(fetched_at="2026-10-21T02:00:00Z")
    assert first["contentHash"] == second["contentHash"]
    reused = reuse_previous_if_unchanged(second, first)
    assert reused["fetchedAt"] == "2026-10-21T02:00:00Z"
    assert {key: value for key, value in reused.items() if key != "fetchedAt"} == {
        key: value for key, value in first.items() if key != "fetchedAt"
    }


def test_trip_count_drop_of_50_percent_fails_and_keeps_the_file(tmp_path, monkeypatch):
    output = tmp_path / "kutsuna.json"
    previous = _document()
    islands = previous["islands"]
    islands["nakajima"][0]["trips"] = islands["nakajima"][0]["trips"] * 20
    previous_text = json.dumps(previous, ensure_ascii=False)
    output.write_text(previous_text, encoding="utf-8")
    monkeypatch.setattr("scripts.fetch_ferry_nakajima.OUTPUT_PATH", output)
    monkeypatch.setattr("scripts.fetch_ferry_nakajima.fetch_timetable_html", lambda: _fixture_html())
    monkeypatch.setattr("scripts.fetch_ferry_nakajima.utc_now_stamp", lambda: "2026-10-21T03:00:00Z")

    assert count_trips(previous) > count_trips(_document()) * 2
    assert main() == 1
    assert output.read_text(encoding="utf-8") == previous_text


def test_main_writes_fixture_document_and_keeps_existing_file_on_parse_failure(tmp_path, monkeypatch):
    output = tmp_path / "kutsuna.json"
    monkeypatch.setattr("scripts.fetch_ferry_nakajima.OUTPUT_PATH", output)
    monkeypatch.setattr("scripts.fetch_ferry_nakajima.fetch_timetable_html", lambda: _fixture_html())
    monkeypatch.setattr("scripts.fetch_ferry_nakajima.utc_now_stamp", lambda: FETCHED_AT)

    assert main() == 0
    written = json.loads(output.read_text(encoding="utf-8"))
    assert written["validFrom"] == "2025-02-01"
    assert written["fetchedAt"] == FETCHED_AT
    validate_document(written, None)

    output.write_text('{"marker": true}\n', encoding="utf-8")
    monkeypatch.setattr(
        "scripts.fetch_ferry_nakajima.fetch_timetable_html",
        lambda: "<html><body><p>broken</p></body></html>",
    )
    assert main() == 1
    assert json.loads(output.read_text(encoding="utf-8")) == {"marker": True}


def test_validation_rejects_a_trip_without_time_or_note():
    document = _document()
    document["islands"]["tsurushima"][0]["trips"][0]["departure"] = None
    document["contentHash"] = content_hash(document["validFrom"], document["islands"])
    with pytest.raises(ValueError, match="departure"):
        validate_document(document, None)


class _FakeResponse:
    def __init__(self, body: bytes):
        self._body = body
        self.headers = self

    def get_content_charset(self):
        return "utf-8"

    def read(self):
        return self._body

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc, tb):
        return False


class _FakeOpener:
    def __init__(self, results):
        self.results = list(results)
        self.requests = []
        self.timeouts = []

    def open(self, request, timeout):
        self.requests.append(request)
        self.timeouts.append(timeout)
        item = self.results.pop(0)
        if isinstance(item, Exception):
            raise item
        return item


def test_fetch_retries_twice_then_stops_and_rejects_https():
    sleeps = []
    opener = _FakeOpener(
        [
            TimeoutError("timed out"),
            TimeoutError("timed out"),
            _FakeResponse("ok".encode("utf-8")),
        ]
    )
    body = fetch_timetable_html(opener=opener, sleep=lambda seconds: sleeps.append(seconds))
    assert body == "ok"
    assert sleeps == [5, 5]
    assert opener.timeouts == [20, 20, 20]
    assert opener.requests[0].get_header("User-agent") == USER_AGENT
    assert opener.requests[0].full_url == SOURCE_URL

    failed = _FakeOpener([TimeoutError("timed out")] * 3)
    with pytest.raises(RuntimeError, match="時刻表の取得に失敗しました"):
        fetch_timetable_html(opener=failed, sleep=lambda _seconds: None)
    assert len(failed.requests) == 3

    redirected = _FakeOpener([NonHttpRedirect("https://example.test/")])
    with pytest.raises(NonHttpRedirect):
        fetch_timetable_html(opener=redirected, sleep=lambda _seconds: None)
    assert len(redirected.requests) == 1

    with pytest.raises(ValueError, match="HTTP のみ"):
        fetch_timetable_html("https://www.nakajimakisen.co.jp/contents/time-table.html")
