# 画像出典台帳・優先確認リスト

最終更新: 2026年7月26日

アプリ内の背景画像・地域カバー・アイコンの帰属を監査可能にするための台帳です。

## 台帳ファイル

| ファイル | 内容 |
|---|---|
| [image-provenance.csv](./image-provenance.csv) | 全画像アセット1行ずつのマスター台帳 |
| [../scripts/download_curated_islands.py](../scripts/download_curated_islands.py) | 一部画像の取得元定義（**最も信頼できるスクリプト**） |
| [../scripts/curated_credits.json](../scripts/curated_credits.json) | クレジット文字列のみ（URL なし・参照用） |
| [../scripts/fetch_results.json](../scripts/fetch_results.json) | Unsplash 自動探索ログ（**最終採用源ではない**） |

### CSV の列

| 列 | 意味 |
|---|---|
| `asset_name` | Xcode アセット名 |
| `file_path` | リポジトリ内の実ファイル |
| `usage` | `island_background` / `region_cover` / `app_icon` 等 |
| `source_type` | `unsplash` / `wikimedia` / `provided_local` / `original` |
| `source_id` | Unsplash slug または Wikimedia ファイル名 |
| `source_url` | 原典ページ URL |
| `verification_priority` | P0（必須）/ P1（高）/ P2（低） |
| `verification_status` | `pending` → 確認後 `verified` または `replace` |
| `verified_by` / `verified_on` | 確認者・日付（空欄のまま手入力） |

---

## 優先度の意味

| 優先度 | 件数（目安） | いつまでに | 理由 |
|---|---|---|---|
| **P0** | 約 24 | **リリース前必須** | CC 義務・台帳未登録・fetch 不一致 |
| **P1** | 約 9 | リリース前推奨 | Unsplash（slug あり）。目視一致確認 |
| **P2** | 6 | 確認済みまたは低リスク | 自作写真 4 枚（verified）・アイコン 2 枚 |

---

## P0 — リリース前に必ず確認（ブロッカー候補）

### A. fetch_results と curated の食い違い — 解消済み（2026-07-26）

| asset | 結果 |
|---|---|
| **IslandBgNaoshima** | 2026-07-30: Unsplash（Hotaria N / `0o_77PCpA8Q`）に差し替え済み（直島・自然風景。ベネッセ作品を含まない） |
| **IslandBgTsurushima** | `tsurushima.jpg` と Wikimedia（Ka23 13 / `Tsurushima_20180814_162343.jpg`）を照合し **一致**。旧 fetch 候補（Unsplash）は未採用 |

### B. 自作写真（開発者撮影）— 確認済み

| asset | 作者 | 状態 |
|---|---|---|
| IslandBgKuroshima | Tomoyuki Shidara | `verified`（台帳・クレジット画面に記載） |
| IslandBgHateruma | Tomoyuki Shidara | 同上 |
| IslandBgHachijojima | Tomoyuki Shidara | 同上 |
| IslandBgInujima | Tomoyuki Shidara | 同上（2026-07-30 開発者撮影に復帰） |
| IslandBgFutagamijima | Tomoyuki Shidara | 同上（2026-08-22 開発者撮影に差し替え） |

島詳細のクレジットは `Photo: Tomoyuki Shidara（島名）`。アプリ内の「自作写真（開発者撮影）」セクションで説明。

### C. Wikimedia Commons（CC / GSI）— 作者・ライセンス・ファイル一致

**共通手順（各画像 5〜10 分）**

1. CSV の `source_url` を開く（五島・一部は File 名を先に特定）
2. 作者名・ライセンスが `credit_text_in_app` と一致するか
3. プレビュー画像と `Assets.xcassets` 内の `.jpg` が同一か（向き・トリミング含む）
4. 「暗色グラデーション追加」がクレジットに書いてあるか（アプリ内 `ImageCreditsView` と一致）
5. OK なら CSV の `verification_status` を `verified`、`verified_on` を記入

| グループ | asset（一覧） |
|---|---|
| 八重山 CC | IslandBgYonaguni, IslandBgKohama, IslandBgHatoma |
| 佐渡島 | IslandBgSado |
| 伊豆 CC | IslandBgOshima, IslandBgToshima, IslandBgShikinejima, IslandBgMikurajima |
| 忽那 CC | IslandBgNakajima, IslandBgGogoshima, IslandBgMuzukijima, IslandBgNogutsunajima, IslandBgTsurushima, IslandBgAijima, IslandBgKutsuna |
| 忽那 GSI | IslandBgNuwajima, IslandBgTsuwajishima |
| 五島 CC | IslandBgGoto, IslandBgFukue, IslandBgHisaka, IslandBgNaru, IslandBgWakamatsu, IslandBgNakadori |

**照合結果**: 41/41 verified（2026-08-16 時点。鳩間・小浜を追加）。照合スクリプト: `python3 scripts/verify_image_provenance.py`

**五島の File 名（照合済み）**

| asset | Commons File 名 |
|---|---|
| IslandBgGoto | 頓泊海水浴場.jpg |
| IslandBgFukue | 堂崎教会 (Dozaki Church) 18 Nov, 2013 - panoramio.jpg |
| IslandBgHisaka | Front view of the Former Gorin Church.jpg |
| IslandBgNaru | 江上天主堂.JPG |
| IslandBgWakamatsu | Wakamatsu_Oohashi.JPG |
| IslandBgNakadori | Aosagaura Church.JPG（青砂ヶ浦教会。旧クレジット「青嵐教会」は誤記） |

**五島の File 名の探し方（例）**

- Commons で「堂崎天主堂」「旧五輪教会」「頓泊海水浴場」「青砂ヶ浦教会」等を検索
- 作者名（Hiroaki Kaneko、Sapphire123 等）で絞り込み
- 見つけた File 名を CSV の `source_id` と `source_url` に追記

---

## P1 — リリース前推奨（Unsplash）

| asset | 原典 | 追加確認 |
|---|---|---|
| IslandBgIshigaki | [uvNQOFjqjns](https://unsplash.com/photos/uvNQOFjqjns) | 川平湾・石垣島タグ |
| IslandBgTaketomi | [kInzQWIYFMA](https://unsplash.com/photos/white-and-brown-concrete-building-under-blue-sky-and-white-clouds-during-daytime-kInzQWIYFMA) | 竹富島タグ |
| IslandBgIriomote | [tFtc8jNnNds](https://unsplash.com/photos/tFtc8jNnNds) | 西表島タグ |
| IslandBgNiijima | [ODBhLvrmvHA](https://unsplash.com/photos/sandy-cliffs-overlook-the-bright-blue-ocean-and-sky-ODBhLvrmvHA) | 白ママ層崖 |
| IslandBgKozushima | [i8bg_aTGloQ](https://unsplash.com/photos/green-and-brown-plant-on-gray-rock-formation-near-blue-sea-during-daytime-i8bg_aTGloQ) | 神津島 |
| IslandBgMiyakejima | [kCsD88x1AM8](https://unsplash.com/photos/brown-rock-formation-on-body-of-water-during-daytime-kCsD88x1AM8) | 三宅島 |
| IslandBgShodoshima | [k6IxsXAObPo](https://unsplash.com/photos/people-walking-on-beach-during-daytime-k6IxsXAObPo) | 小豆島 |
| IslandBgNaoshima | [0o_77PCpA8Q](https://unsplash.com/photos/a-small-island-in-the-middle-of-a-body-of-water-0o_77PCpA8Q) | 直島・Hotaria N |
| IslandBgTeshima | [xkT72lieaW0](https://unsplash.com/photos/green-trees-near-body-of-water-during-daytime-xkT72lieaW0) | 豊島・Victor Lu |
| IslandBgInujima | （開発者撮影） | Tomoyuki Shidara・犬島 |
| IslandBgShodoshimaNaoshima | 上と同一 slug | `shodoshima.jpg` と `shodoshima_naoshima.jpg` の同一性 |
| IslandBgIzu | Kozushima と同一 slug | `kozushima.jpg` と `izu.jpg` の同一性 |

---

## P2 — 低優先

| asset | 内容 |
|---|---|
| AppIcon-1024 | オリジナルアイコン（クレジット画面に記載済み） |
| AppBrandIcon | アプリ内ブランド用（要・使用意図の確認のみ） |

---

## 確認の進め方（推奨順）

```
1. P0-C 五島（6 枚）                ← File 名特定から
2. P0-C その他 Wikimedia（約 16 枚）
3. P1 Unsplash（残り）
4. P2 自作写真・アイコン（6 件）
```

1日あたり 10〜15 枚ペースなら、**P0+P1 は 2〜3 日**が目安です。

---

## 確認後の更新ルール

1. **CSV を先に更新**（`verified` / `replace`、日付、メモ）
2. クレジット修正が必要なら `*IslandProfiles.swift` と `IslandRegionCatalog.swift` を更新
3. `curated_credits.json` は CSV 確定後に同期（または廃止して CSV を正とする）
4. `fetch_results.json` は参照用ログとして残してよいが、**台帳の根拠にしない**

---

## 差し替えが必要になった場合

| 選択肢 | 向いているケース |
|---|---|
| 自作写真（Tomoyuki Shidara） | 現地撮影がある島 |
| Unsplash（slug・URL 付きで台帳登録） | 場所タグが明確な写真 |
| Wikimedia（File ページ URL 必須） | CC 画像で原典が追えるもの |

**確認できない画像はリリースに含めない**のが安全です。

---

## 関連

- アプリ内表示: `ImageCreditsView.swift`
- 取得スクリプト: `scripts/download_curated_islands.py`
- 提出用チェック: `submission-checklist-ja.md`（画像権利の項目を追加推奨）
