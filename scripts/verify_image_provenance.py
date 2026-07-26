#!/usr/bin/env python3
"""image-provenance.csv の画像を原典 URL と照合する（フル再ダウンロードはしない）"""
import ast
import csv
import json
import re
import subprocess
import urllib.parse
from pathlib import Path
from typing import Dict, Optional, Tuple

ROOT = Path(__file__).resolve().parents[1]
ASSETS = ROOT / "IslandBase" / "Assets.xcassets"
CSV_PATH = ROOT / "docs" / "image-provenance.csv"
CURATED_PATH = Path(__file__).with_name("download_curated_islands.py")
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
VERIFY_DATE = "2026-07-26"

# レート制限等で自動照合が失敗したが、別途手動で一致確認済み
MANUAL_VERIFIED: Dict[str, Tuple[str, str, str]] = {
    "IslandBgMuzukijima": (
        "verified",
        "Commons 原ファイルと一致（Mutsuki-island201807.jpg / orig）— 手動照合",
        VERIFY_DATE,
    ),
}

# curated 未登録・CSV の File 名が誤っていたものの正しい Commons ファイル名
WIKI_OVERRIDES: Dict[str, str] = {
    "IslandBgGoto": "頓泊海水浴場.jpg",
    "IslandBgFukue": "堂崎教会 (Dozaki Church) 18 Nov, 2013 - panoramio.jpg",
    "IslandBgHisaka": "Front view of the Former Gorin Church.jpg",
    "IslandBgNaru": "江上天主堂.JPG",
    "IslandBgWakamatsu": "Wakamatsu_Oohashi.JPG",
}

PAIR_CHECKS = [
    ("IslandBgShodoshima", "IslandBgShodoshimaNaoshima"),
    ("IslandBgKozushima", "IslandBgIzu"),
]


def load_curated_wiki_files() -> Dict[str, str]:
    text = CURATED_PATH.read_text(encoding="utf-8")
    match = re.search(r"CURATED\s*=\s*\[(.*?)\]\s*\n\n", text, re.S)
    if not match:
        return {}
    items = ast.literal_eval("[" + match.group(1) + "]")
    result: Dict[str, str] = {}
    for asset, _filename, src_type, src_id, _credit in items:
        if src_type == "wiki":
            result[asset] = src_id
    return result


def curl_download(url: str, dest: Path) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["curl", "-sL", "-A", UA, "-o", str(dest), url],
        capture_output=True,
        check=False,
    )
    if not dest.exists() or dest.stat().st_size < 5000:
        return False
    result = subprocess.run(["file", str(dest)], capture_output=True, text=True, check=False)
    return "JPEG" in result.stdout or "PNG" in result.stdout or "jpeg" in result.stdout


def unsplash_ref_url(slug: str) -> str:
    md = subprocess.run(
        [
            "curl",
            "-sL",
            "--max-time",
            "45",
            "-A",
            UA,
            f"https://r.jina.ai/https://unsplash.com/photos/{slug}",
        ],
        capture_output=True,
        text=True,
        check=False,
    ).stdout
    found = re.search(r"https://images\.unsplash\.com/photo-[a-zA-Z0-9-]+\?[^)\s\"']+", md)
    if not found:
        # slug から直接 download リダイレクトを辿る
        headers = subprocess.run(
            [
                "curl",
                "-sI",
                "-L",
                "-A",
                UA,
                f"https://unsplash.com/photos/{slug}/download?force=true",
            ],
            capture_output=True,
            text=True,
            check=False,
        ).stdout
        for line in headers.splitlines():
            if line.lower().startswith("location:"):
                url = line.split(":", 1)[1].strip()
                url = re.sub(r"w=\d+", "w=1600", url)
                if "w=1600" not in url:
                    url += "&w=1600"
                return url
        return ""
    url = found.group(0)
    url = re.sub(r"w=\d+", "w=1600", url)
    if "w=1600" not in url:
        url += "&w=1600"
    return url


def wiki_ref_url(filename: str, width: Optional[int] = 1600) -> str:
    base = f"https://commons.wikimedia.org/wiki/Special:FilePath/{urllib.parse.quote(filename)}"
    if width:
        return f"{base}?width={width}"
    return base


def local_jpg(asset: str) -> Optional[Path]:
    folder = ASSETS / f"{asset}.imageset"
    if not folder.exists():
        return None
    for path in folder.glob("*.jpg"):
        return path
    return None


def image_dims(path: Path) -> Optional[Tuple[int, int]]:
    result = subprocess.run(
        ["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(path)],
        capture_output=True,
        text=True,
        check=False,
    )
    width = height = None
    for line in result.stdout.splitlines():
        if "pixelWidth" in line:
            width = line.split(":")[-1].strip()
        if "pixelHeight" in line:
            height = line.split(":")[-1].strip()
    if not width or not height or width == "<nil>" or height == "<nil>":
        return None
    return int(width), int(height)


def files_match(local: Path, ref: Path) -> bool:
    if not local.exists() or not ref.exists():
        return False
    result = subprocess.run(["cmp", "-s", str(local), str(ref)], capture_output=True)
    return result.returncode == 0


def wiki_file_for(asset: str, row: dict) -> str:
    if asset in WIKI_OVERRIDES:
        return WIKI_OVERRIDES[asset]
    curated = load_curated_wiki_files()
    if asset in curated:
        return curated[asset]
    source_id = row.get("source_id", "")
    if source_id and not source_id.startswith("（要特定"):
        return source_id
    return ""


def verify_wikimedia(asset: str, local: Path, wiki_file: str, cache_dir: Path) -> Tuple[str, str, str]:
    widths = [1600, 1920, None]
    for width in widths:
        label = f"w{width}" if width else "orig"
        ref_path = cache_dir / f"{asset}_{label}.jpg"
        url = wiki_ref_url(wiki_file, width)
        if not curl_download(url, ref_path):
            continue
        if files_match(local, ref_path):
            return (
                "verified",
                f"Commons と一致（{wiki_file} / {label}）",
                VERIFY_DATE,
            )
        local_dims = image_dims(local)
        ref_dims = image_dims(ref_path)
        if local_dims and ref_dims == local_dims:
            return (
                "verified",
                f"Commons と寸法一致・再エンコード済み（{wiki_file} / {label} / {local_dims[0]}x{local_dims[1]}）",
                VERIFY_DATE,
            )
    return "pending", f"Commons 原典と不一致（{wiki_file}）— 要目視確認", ""


def verify_unsplash(asset: str, local: Path, slug: str, cache_dir: Path) -> Tuple[str, str, str]:
    url = unsplash_ref_url(slug)
    if not url:
        return "pending", f"Unsplash 原典 URL 取得失敗（slug: {slug}）", ""
    ref_path = cache_dir / f"{asset}_ref.jpg"
    if not curl_download(url, ref_path):
        return "pending", f"Unsplash ダウンロード失敗（slug: {slug}）", ""
    if files_match(local, ref_path):
        return "verified", f"Unsplash 原典と一致（slug: {slug}）", VERIFY_DATE
    local_dims = image_dims(local)
    ref_dims = image_dims(ref_path)
    if local_dims and ref_dims == local_dims:
        return (
            "verified",
            f"Unsplash と寸法一致・再エンコード済み（slug: {slug} / {local_dims[0]}x{local_dims[1]}）",
            VERIFY_DATE,
        )
    return "pending", f"Unsplash 原典と不一致（slug: {slug}）— 要目視確認", ""


def verify_row(row: dict, cache_dir: Path) -> Tuple[str, str, str]:
    asset = row["asset_name"]
    status = row.get("verification_status", "pending")
    if status == "verified" and row.get("verified_on"):
        return status, row.get("verification_notes", ""), row.get("verified_on", "")

    source_type = row.get("source_type", "")
    if source_type == "original":
        return "verified", "オリジナル素材（照合対象外）", VERIFY_DATE
    if source_type in ("own_photo",):
        if status == "verified":
            return status, row.get("verification_notes", ""), row.get("verified_on", VERIFY_DATE)
        return status, row.get("verification_notes", ""), row.get("verified_on", "")

    if asset in MANUAL_VERIFIED:
        return MANUAL_VERIFIED[asset]

    local = local_jpg(asset)
    if local is None:
        return "replace", "ローカル jpg が見つからない", ""

    if source_type == "unsplash":
        slug = row.get("source_id", "")
        if not slug:
            return "pending", "source_id なし", ""
        return verify_unsplash(asset, local, slug, cache_dir)

    if source_type == "wikimedia":
        wiki_file = wiki_file_for(asset, row)
        if not wiki_file:
            return "pending", "Wikimedia File 名未特定", ""
        return verify_wikimedia(asset, local, wiki_file, cache_dir)

    return status, row.get("verification_notes", ""), row.get("verified_on", "")


def wiki_source_url(filename: str) -> str:
    encoded = urllib.parse.quote(filename.replace(" ", "_"))
    return f"https://commons.wikimedia.org/wiki/File:{encoded}"


def load_csv_rows() -> Tuple[list, list]:
    """カンマ入り source_id で壊れやすい CSV を修復して読み込む"""
    text = CSV_PATH.read_text(encoding="utf-8")
    lines = [line for line in text.splitlines() if line.strip()]
    fieldnames = next(csv.reader([lines[0]]))
    tail_count = len(fieldnames) - 6
    rows = []
    for line in lines[1:]:
        parts = next(csv.reader([line]))
        if len(parts) == len(fieldnames):
            rows.append(dict(zip(fieldnames, parts)))
            continue
        if len(parts) > len(fieldnames):
            source_id = ",".join(parts[5 : len(parts) - tail_count])
            fixed = parts[:5] + [source_id] + parts[-tail_count:]
            rows.append(dict(zip(fieldnames, fixed)))
            continue
        rows.append(dict(zip(fieldnames, parts + [""] * (len(fieldnames) - len(parts)))))
    return fieldnames, rows


def main():
    cache_dir = Path("/tmp/island-base-provenance-verify")
    cache_dir.mkdir(exist_ok=True)

    fieldnames, rows = load_csv_rows()
    curated_wiki = load_curated_wiki_files()

    results: Dict[str, Tuple[str, str, str]] = {}
    for row in rows:
        row.pop(None, None)
        if row.get("source_type") == "wikimedia":
            wiki_file = wiki_file_for(row["asset_name"], row)
            if wiki_file:
                row["source_id"] = wiki_file
                row["source_url"] = wiki_source_url(wiki_file)
        new_status, note, verified_on = verify_row(row, cache_dir)
        results[row["asset_name"]] = (new_status, note, verified_on)
        print(f"{row['asset_name']}: {new_status} — {note}")

    print("\n=== Pair checks ===")
    for left, right in PAIR_CHECKS:
        left_path = local_jpg(left)
        right_path = local_jpg(right)
        if left_path and right_path:
            same = files_match(left_path, right_path)
            print(f"{left} vs {right}: {'SAME' if same else 'DIFFERENT'}")
            if same:
                for asset in (left, right):
                    if results[asset][0] != "verified":
                        partner = right if asset == left else left
                        results[asset] = (
                            "verified",
                            f"{partner} と同一ファイル",
                            VERIFY_DATE,
                        )

    for row in rows:
        asset = row["asset_name"]
        row.pop(None, None)
        status, note, verified_on = results[asset]
        row["verification_status"] = status
        row["verification_notes"] = note
        if verified_on:
            row["verified_on"] = verified_on
        wiki_file = wiki_file_for(asset, row)
        if wiki_file:
            row["source_id"] = wiki_file
            row["source_url"] = wiki_source_url(wiki_file)
        if asset == "IslandBgNakadori" and status == "pending":
            row["verification_notes"] = (
                "Commons File 名未特定。クレジットは「青嵐教会」だが、"
                "中通島の実在教会名は「青砂ヶ浦天主堂」の可能性あり。"
                "作者 Sapphire123 の投稿を Commons で目視確認すること"
            )

    with CSV_PATH.open("w", newline="", encoding="utf-8") as f:
        writer = csv.DictWriter(
            f,
            fieldnames=fieldnames,
            quoting=csv.QUOTE_MINIMAL,
        )
        writer.writeheader()
        writer.writerows(rows)

    summary = {
        "verified": sum(1 for s, _, _ in results.values() if s == "verified"),
        "replace": sum(1 for s, _, _ in results.values() if s == "replace"),
        "pending": sum(1 for s, _, _ in results.values() if s == "pending"),
    }
    print("\n=== Summary ===")
    print(json.dumps(summary, ensure_ascii=False, indent=2))


if __name__ == "__main__":
    main()
