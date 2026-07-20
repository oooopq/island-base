#!/usr/bin/env python3
"""確認済みの島背景画像を一括ダウンロード"""
import json
import time
import subprocess
import urllib.parse
from pathlib import Path

BASE = Path(__file__).resolve().parents[1] / "IslandBase" / "Assets.xcassets"
UA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36"
WIKI_API = "https://commons.wikimedia.org/w/api.php"

# (asset, filename, source_type, source_id, credit)
# source_type: unsplash_slug | unsplash_img | wiki_file
CURATED = [
    # 八重山 — Unsplash（場所タグ確認済み）
    ("IslandBgIshigaki", "ishigaki.jpg", "unsplash_slug", "uvNQOFjqjns", "Photo: Roméo A. / Unsplash（石垣島・川平湾）"),
    ("IslandBgTaketomi", "taketomi.jpg", "unsplash_slug", "white-and-brown-concrete-building-under-blue-sky-and-white-clouds-during-daytime-kInzQWIYFMA", "Photo: Hiroko Yoshii / Unsplash（竹富島）"),
    ("IslandBgIriomote", "iriomote.jpg", "unsplash_slug", "tFtc8jNnNds", "Photo: Wataru Sato / Unsplash（西表島）"),
    # 八重山 — Wikimedia（Unsplashに場所タグ付き写真なし）
    ("IslandBgKuroshima", "kuroshima.jpg", "local", "", "Photo: TOMOYUKI SHIDARA（黒島）"),
    ("IslandBgHateruma", "hateruma.jpg", "local", "", "Photo: TOMOYUKI SHIDARA（波照間島・西浜）"),
    ("IslandBgYonaguni", "yonaguni.jpg", "wiki", "Yonaguni_agarizaki.jpg", "Photo: Metatron / Wikimedia Commons（与那国島・東崎）／CC BY-SA 3.0／表示時に暗色グラデーションを追加"),
    # 佐渡
    ("IslandBgSado", "sado.jpg", "wiki", "矢島経島たらい舟_-_panoramio.jpg", "Photo: 伊藤善行 / Wikimedia Commons（佐渡・矢島経島のたらい舟）／CC BY-SA 3.0／表示時に暗色グラデーションを追加"),
    # 伊豆 — Wikimedia
    ("IslandBgOshima", "oshima.jpg", "wiki", "Izu-Oshima-IMG_4759.jpg", "Photo: Donners / Wikimedia Commons（伊豆大島）／CC BY-SA 1.0／表示時に暗色グラデーションを追加"),
    ("IslandBgToshima", "toshima.jpg", "wiki", "Toshima_Island_from_offshore,_Tokyo,_Japan.JPG", "Photo: User: (WT-shared) Shoestring / Wikimedia Commons（利島・東京）／CC BY-SA 4.0／表示時に暗色グラデーションを追加"),
    ("IslandBgNiijima", "niijima.jpg", "unsplash_slug", "sandy-cliffs-overlook-the-bright-blue-ocean-and-sky-ODBhLvrmvHA", "Photo: Fumiaki Hayashi / Unsplash（新島・白ママ層崖）"),
    ("IslandBgShikinejima", "shikinejima.jpg", "wiki", "Shikinejima,_Niijima,_Tokyo_100-0511,_Japan_-_panoramio.jpg", "Photo: takeakisky homma / Wikimedia Commons（式根島・泊海水浴場）／CC BY-SA 3.0／表示時に暗色グラデーションを追加"),
    ("IslandBgKozushima", "kozushima.jpg", "unsplash_slug", "green-and-brown-plant-on-gray-rock-formation-near-blue-sea-during-daytime-i8bg_aTGloQ", "Photo: Ice Tea / Unsplash（神津島）"),
    ("IslandBgMiyakejima", "miyakejima.jpg", "unsplash_slug", "brown-rock-formation-on-body-of-water-during-daytime-kCsD88x1AM8", "Photo: Marek Okon / Unsplash（三宅島）"),
    ("IslandBgMikurajima", "mikurajima.jpg", "wiki", "Wharf_in_Mikurajima.jpg", "Photo: 名古屋太郎 / Wikimedia Commons（御蔵島）／Public domain／表示時に暗色グラデーションを追加"),
    ("IslandBgHachijojima", "hachijojima.jpg", "wiki", "Hachijojima_airport2.jpg", "Photo: ブルーノ・プラス / Wikimedia Commons（八丈島）／CC BY-SA 4.0／表示時に暗色グラデーションを追加"),
    # 忽那諸島 — Wikimedia
    ("IslandBgNakajima", "nakajima.jpg", "wiki", "Amiage-_Beach.jpg", "Photo: melvil / Wikimedia Commons（中島・網明海岸）／CC BY-SA 4.0／表示時に暗色グラデーションを追加"),
    ("IslandBgGogoshima", "gogoshima.jpg", "wiki", "Gogoshima_01.JPG", "Photo: Reggaeman / Wikimedia Commons（興居島）／CC BY-SA 3.0／表示時に暗色グラデーションを追加"),
    ("IslandBgMuzukijima", "muzukijima.jpg", "wiki", "Mutsuki-island201807.jpg", "Photo: melvil / Wikimedia Commons（睦月島）／CC BY-SA 4.0／表示時に暗色グラデーションを追加"),
    ("IslandBgNogutsunajima", "nogutsunajima.jpg", "wiki", "Nogutsuna_Island,_Ehime,_Japan_26-May-2018.jpg", "Photo: 全樺連 / Wikimedia Commons（野忽那島）／CC BY-SA 4.0／表示時に暗色グラデーションを追加"),
    ("IslandBgNuwajima", "nuwajima.jpg", "wiki", "Nuwa_jima_Island_Aerial_photograph.2019.jpg", "Photo: 国土地理院 / Wikimedia Commons（怒和島・愛媛）／出典：国土地理院／表示時に暗色グラデーションを追加"),
    ("IslandBgTsuwajishima", "tsuwajishima.jpg", "wiki", "Tsuwaji_jima_Island_Aerial_photograph.2019.jpg", "Photo: 国土地理院 / Wikimedia Commons（津和地島・愛媛）／出典：国土地理院／表示時に暗色グラデーションを追加"),
    ("IslandBgFutagamijima", "futagamijima.jpg", "wiki", "Futagami_jima_Island_Aerial_photograph.2019.jpg", "Photo: 国土地理院 / Wikimedia Commons（二神島・愛媛）／出典：国土地理院／表示時に暗色グラデーションを追加"),
    ("IslandBgTsurushima", "tsurushima.jpg", "wiki", "Tsurushima_20180814_162343.jpg", "Photo: Ka23 13 / Wikimedia Commons（釣島）／CC BY 4.0／表示時に暗色グラデーションを追加"),
    ("IslandBgAijima", "aijima.jpg", "wiki", "Aijima_Island,_Ehime,_Japan_26-May-2018.jpg", "Photo: 全樺連 / Wikimedia Commons（安居島）／CC BY-SA 4.0／表示時に暗色グラデーションを追加"),
    # 小豆島・直島 — Unsplash
    ("IslandBgShodoshima", "shodoshima.jpg", "unsplash_slug", "people-walking-on-beach-during-daytime-k6IxsXAObPo", "Photo: Yu / Unsplash（小豆島・香川）"),
    ("IslandBgNaoshima", "naoshima.jpg", "unsplash_slug", "a-yellow-and-black-fruit-3ItvceJh4hY", "Photo: Rahil Chadha / Unsplash（直島）"),
    ("IslandBgTeshima", "teshima.jpg", "unsplash_slug", "people-inside-building-with-large-roof-hole-dP9zGPDQi6w", "Photo: Denis Kovalev / Unsplash（豊島・豊島美術館）"),
    ("IslandBgShodoshimaNaoshima", "shodoshima_naoshima.jpg", "unsplash_slug", "people-walking-on-beach-during-daytime-k6IxsXAObPo", "Photo: Yu / Unsplash（小豆島・香川）"),
    # 地域カバー
    ("IslandBgIzu", "izu.jpg", "unsplash_slug", "green-and-brown-plant-on-gray-rock-formation-near-blue-sea-during-daytime-i8bg_aTGloQ", "Photo: Ice Tea / Unsplash（神津島・伊豆諸島）"),
    ("IslandBgKutsuna", "kutsuna.jpg", "wiki", "興居島沖合 - panoramio.jpg", "Photo: KUNIO MIURA / Wikimedia Commons（興居島沖合）／CC BY 3.0／表示時に暗色グラデーションを追加"),
]


def curl(args):
    return subprocess.run(["curl", "-sL", "-A", UA, *args], capture_output=True, text=True)


def unsplash_img_url(slug: str) -> str:
    md = curl(["--max-time", "30", f"https://r.jina.ai/https://unsplash.com/photos/{slug}"]).stdout
    import re
    m = re.search(r"https://images\.unsplash\.com/photo-[a-zA-Z0-9-]+\?[^)\s\"']+", md)
    if not m:
        return ""
    url = m.group(0)
    url = re.sub(r"w=\d+", "w=1600", url)
    if "w=1600" not in url:
        url += "&w=1600"
    return url


def wiki_img_url(filename: str) -> str:
    return f"https://commons.wikimedia.org/wiki/Special:FilePath/{urllib.parse.quote(filename)}?width=1600"


def download(url: str, dest: Path) -> bool:
    dest.parent.mkdir(parents=True, exist_ok=True)
    subprocess.run(["curl", "-sL", "-A", UA, "-o", str(dest), url], capture_output=True)
    if not dest.exists() or dest.stat().st_size < 5000:
        return False
    r = subprocess.run(["file", str(dest)], capture_output=True, text=True, errors="replace")
    return "JPEG" in r.stdout or "jpeg" in r.stdout or "PNG" in r.stdout


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
    credits = {}
    for asset, filename, src_type, src_id, credit in CURATED:
        if src_type == "local":
            credits[asset] = credit
            print(f"SKIP (local) {asset}")
            continue
        if src_type == "unsplash_slug":
            url = unsplash_img_url(src_id)
        else:
            url = wiki_img_url(src_id)
        if not url:
            print(f"NO URL {asset}")
            continue
        dest = BASE / f"{asset}.imageset" / filename
        ok = download(url, dest)
        if ok:
            write_contents(BASE / f"{asset}.imageset", filename)
            credits[asset] = credit
            print(f"OK {asset}")
        else:
            print(f"FAIL {asset} {url[:80]}")
        time.sleep(0.5)
    out = Path(__file__).parent / "curated_credits.json"
    out.write_text(json.dumps(credits, ensure_ascii=False, indent=2))
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
