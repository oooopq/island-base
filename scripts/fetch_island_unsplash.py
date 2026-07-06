#!/usr/bin/env python3
"""Unsplash: 島名検索 → 個別ページで場所タグ確認 → images.unsplash.com から取得"""
import json
import re
import subprocess
import time
import urllib.parse
from pathlib import Path

BASE = Path(__file__).resolve().parents[1] / "IslandNow" / "Assets.xcassets"
JINA = "https://r.jina.ai/https://unsplash.com"
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"

# island_keys: ページ全文に含まれるべき語（いずれか）
# reject_keys: 含まれていたら別島とみなして除外
ISLANDS = [
    ("IslandBgIshigaki", "ishigaki.jpg", ["ishigaki island okinawa", "石垣島"], ["ishigaki", "石垣"], ["miyako", "宮古", "taketomi", "竹富"]),
    ("IslandBgTaketomi", "taketomi.jpg", ["taketomi island okinawa", "竹富島"], ["taketomi", "竹富"], ["miyako", "宮古", "ishigaki", "石垣"]),
    ("IslandBgKuroshima", "kuroshima.jpg", ["kuroshima yaeyama", "黒島 八重山", "kuroshima island okinawa"], ["kuroshima", "黒島", "yaeyama"], ["miyako", "宮古", "ishigaki", "石垣", "taketomi", "竹富", "iriomote", "西表"]),
    ("IslandBgHateruma", "hateruma.jpg", ["hateruma island", "波照間島"], ["hateruma", "波照間"], ["miyako", "ishigaki", "石垣"]),
    ("IslandBgIriomote", "iriomote.jpg", ["iriomote island okinawa", "西表島"], ["iriomote", "西表"], ["taketomi", "竹富", "miyako", "ishigaki"]),
    ("IslandBgYonaguni", "yonaguni.jpg", ["yonaguni island okinawa", "与那国島"], ["yonaguni", "与那国"], ["ishigaki", "miyako"]),
    ("IslandBgSado", "sado.jpg", ["sado island japan", "佐渡島"], ["sado", "佐渡"], ["okinawa", "沖縄"]),
    ("IslandBgOshima", "oshima.jpg", ["izu oshima island", "伊豆大島"], ["izu oshima", "伊豆大島", "大島 伊豆"], ["okinawa", "sado", "佐渡"]),
    ("IslandBgToshima", "toshima.jpg", ["izu toshima island", "利島 伊豆"], ["toshima", "利島"], ["okinawa", "sado"]),
    ("IslandBgNiijima", "niijima.jpg", ["niijima island japan", "新島 伊豆"], ["niijima", "新島"], ["okinawa"]),
    ("IslandBgShikinejima", "shikinejima.jpg", ["shikinejima", "式根島"], ["shikine", "式根"], []),
    ("IslandBgKozushima", "kozushima.jpg", ["kozushima island", "神津島"], ["kozushima", "神津"], []),
    ("IslandBgMiyakejima", "miyakejima.jpg", ["miyakejima", "三宅島"], ["miyake", "三宅"], ["miyakojima", "宮古"]),
    ("IslandBgMikurajima", "mikurajima.jpg", ["mikurajima", "御蔵島"], ["mikura", "御蔵"], []),
    ("IslandBgHachijojima", "hachijojima.jpg", ["hachijojima", "八丈島"], ["hachijo", "八丈"], []),
    ("IslandBgNakajima", "nakajima.jpg", ["nakajima ehime kutsuna", "中島 愛媛"], ["nakajima", "中島", "kutsuna", "忽那", "ehime"], ["okinawa", "広島"]),
    ("IslandBgGogoshima", "gogoshima.jpg", ["gogoshima ehime", "興居島"], ["gogoshima", "興居", "koge"], ["matsuyama castle", "松山城"]),
    ("IslandBgMuzukijima", "muzukijima.jpg", ["muzukijima ehime", "睦月島"], ["muzuki", "睦月"], []),
    ("IslandBgNogutsunajima", "nogutsunajima.jpg", ["nogutsunajima", "野忽那島"], ["nogutsuna", "野忽那"], []),
    ("IslandBgNuwajima", "nuwajima.jpg", ["nuwajima ehime", "怒和島"], ["nuwa", "怒和"], []),
    ("IslandBgTsuwajishima", "tsuwajishima.jpg", ["tsuwajishima ehime", "津和地島"], ["tsuwaji", "津和地"], []),
    ("IslandBgFutagamijima", "futagamijima.jpg", ["futagamijima ehime", "二神島"], ["futagami", "二神"], []),
    ("IslandBgTsurushima", "tsurushima.jpg", ["tsurushima ehime", "釣島 愛媛"], ["tsurushima", "釣島", "tsuru"], []),
    ("IslandBgAijima", "aijima.jpg", ["aijima ehime kutsuna", "安居島 愛媛"], ["aijima", "安居"], []),
    ("IslandBgShodoshima", "shodoshima.jpg", ["shodoshima kagawa", "小豆島"], ["shodoshima", "小豆"], ["naoshima", "直島"]),
    ("IslandBgNaoshima", "naoshima.jpg", ["naoshima kagawa japan", "直島 香川"], ["naoshima", "直島"], ["shodoshima", "小豆", "teshima", "豊島"]),
    ("IslandBgTeshima", "teshima.jpg", ["teshima art museum", "豊島 香川"], ["teshima", "豊島"], ["naoshima", "直島", "shodoshima"]),
    ("IslandBgShodoshimaNaoshima", "shodoshima_naoshima.jpg", ["shodoshima setouchi", "小豆島 瀬戸内"], ["shodoshima", "小豆", "setouchi", "kagawa"], ["naoshima", "直島"]),
]


def curl_text(url: str) -> str:
    r = subprocess.run(
        ["curl", "-sL", "--max-time", "30", "-A", UA, url],
        capture_output=True,
        text=True,
    )
    return r.stdout


def search_slugs(query: str) -> list:
    encoded = urllib.parse.quote(query)
    md = curl_text(f"{JINA}/s/photos/{encoded}")
    slugs = re.findall(r"unsplash\.com/photos/([a-zA-Z0-9_-]+)", md)
    seen, out = set(), []
    for s in slugs:
        if s in ("download", "plus") or s.startswith("a-"):
            continue
        if s not in seen:
            seen.add(s)
            out.append(s)
    return out[:15]


def parse_photo_page(slug: str) -> dict:
    md = curl_text(f"{JINA}/photos/{slug}")
    if len(md) < 300:
        return {}
    photographer = "Unknown"
    m = re.search(r"Photo by (.+?) on Unsplash", md)
    if m:
        photographer = m.group(1).strip()
    # 場所行（例: Taketomi Island, 字竹富 ...）
    place_line = ""
    for line in md.splitlines():
        if re.search(r"(Island|島|町|Japan|日本)", line) and len(line) < 120:
            if "Download" not in line and "Unsplash" not in line and "http" not in line:
                place_line = line.strip()
                if "Island" in place_line or "島" in place_line:
                    break
    img_m = re.search(r"https://images\.unsplash\.com/photo-[a-zA-Z0-9-]+\?[^)\s\"']+", md)
    img_url = img_m.group(0) if img_m else ""
    if img_url:
        img_url = re.sub(r"w=\d+", "w=1600", img_url)
        if "w=1600" not in img_url:
            img_url += "&w=1600"
        img_url = re.sub(r"q=\d+", "q=85", img_url)
    return {
        "slug": slug,
        "photographer": photographer,
        "place_line": place_line,
        "full_text": md.lower(),
        "img_url": img_url,
    }


def matches(info: dict, island_keys: list, reject_keys: list) -> bool:
    if not info or not info.get("img_url"):
        return False
    text = info["full_text"] + " " + info.get("place_line", "").lower()
    if reject_keys and any(k.lower() in text for k in reject_keys):
        # 島名キーも一致していれば reject は無視（例: ishigaki と ishigaki island 両方）
        pass
    else:
        if reject_keys:
            for k in reject_keys:
                if k.lower() in text:
                    # 明示的な別島名
                    if not any(ik.lower() in text for ik in island_keys):
                        return False
    return any(k.lower() in text for k in island_keys)


def download_img(url: str, dest: Path) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(
        ["curl", "-sL", "-A", UA, "-o", str(dest), url],
        capture_output=True,
    )
    if not dest.exists() or dest.stat().st_size < 8000:
        return False
    r = subprocess.run(["file", str(dest)], capture_output=True, text=True)
    return "JPEG" in r.stdout or "jpeg" in r.stdout


def write_contents(folder: Path, filename: str):
    (folder / "Contents.json").write_text(
        json.dumps(
            {
                "images": [
                    {"filename": filename, "idiom": "universal", "scale": "1x"},
                    {"idiom": "universal", "scale": "2x"},
                    {"idiom": "universal", "scale": "3x"},
                ],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        )
        + "\n"
    )


def main():
    results = []
    for asset, filename, queries, island_keys, reject_keys in ISLANDS:
        found = None
        for q in queries:
            for slug in search_slugs(q):
                info = parse_photo_page(slug)
                if matches(info, island_keys, reject_keys):
                    found = info
                    break
                time.sleep(0.25)
            if found:
                break
            time.sleep(0.4)
        folder = BASE / f"{asset}.imageset"
        dest = folder / filename
        if found:
            ok = download_img(found["img_url"], dest)
            if ok:
                write_contents(folder, filename)
                results.append(
                    {
                        "asset": asset,
                        "status": "ok",
                        "slug": found["slug"],
                        "photographer": found["photographer"],
                        "place": found["place_line"],
                    }
                )
                print(f"OK {asset}: {found['photographer']} | {found['place_line'][:70]}")
            else:
                results.append({"asset": asset, "status": "download_failed", **found})
                print(f"FAIL dl {asset}")
        else:
            results.append({"asset": asset, "status": "not_found"})
            print(f"NOT FOUND {asset}")
        time.sleep(0.6)
    out = Path(__file__).parent / "fetch_results.json"
    out.write_text(json.dumps(results, ensure_ascii=False, indent=2))
    print(f"\nWrote {out}")


if __name__ == "__main__":
    main()
