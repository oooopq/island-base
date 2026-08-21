# 天気キャッシュ改修 — 設計書

Cloud Agent で検討した内容のまとめです。Mac 上の Cursor で実装するときは `.cursor/rules/weather-cache.mdc` も参照してください。

## 背景・目的

| 現状 | 改修後 |
|------|--------|
| アプリが島ごとに Open-Meteo を直接呼び出し | GitHub Actions が全島をバッチ取得し GitHub Pages に静的 JSON 配信 |
| ユーザー数に比例して API コールが増える | Open-Meteo への実コールを **48 HTTP リクエスト/日**に固定 |
| — | 既存の天気 UI・`WeatherInfo` は変更せず、取得元のみ差し替え |

## アーキテクチャ

```
GitHub Actions（毎時 JST :10）
  ├─ scripts/weather_locations.json を読む（35島の天気地点）
  ├─ Open-Meteo forecast API … 1回（全島バッチ）
  ├─ Open-Meteo marine API … 1回（全島バッチ）
  ├─ WeatherService.swift と同じ変換ロジックで JSON 化
  ├─ 全島検証 OK → docs/weather/{island-id}.json を書き込み
  └─ main に push → GitHub Pages 配信

iOS アプリ
  ├─ GET https://oooopq.github.io/island-base/weather/{id}.json?h=YYYYMMDDHH
  ├─ updatedAt → WeatherInfo.fetchedAt にマッピング
  ├─ UserDefaults（weather_cache_v6_{id}）に保存
  └─ 取得失敗 → UserDefaults の直近キャッシュ or エラー表示
```

## GitHub Actions

### ワークフロー

- ファイル: `.github/workflows/weather-cache.yml`（未作成）
- スケジュール: `cron: '10 * * * *'`（UTC。毎時 :10 UTC = 毎時 :10 JST。`:00` は Open-Meteo 更新との競合を避ける。`timezone` キーは GitHub cron では無効）
- 手動実行: `workflow_dispatch`（初回・デバッグ用）

### 失敗時ポリシー

| 結果 | 動作 |
|------|------|
| 全35島の取得・変換・検証が成功 | `docs/weather/` を更新して commit |
| 1島でも失敗 | **commit しない**（前回の Pages 配信を維持） |

### Open-Meteo コール数

- 1実行あたり 2 HTTP リクエスト（forecast + marine）
- 24 回/日 × 2 = **48 リクエスト/日**（無料枠 10,000/日 に対して十分余裕）

## 座標の正本

`scripts/weather_locations.json`（35島）

- 各島の `IslandProfile.resolvedWeatherLocation` と一致（現状は全島「先頭の港」）
- `weatherLocation` 未設定の島は先頭港座標を使用
- 西表島は大原港（`ports` 配列の先頭）
- 小豆島は `shodoshimaPort`（土庄港）を参照

島を追加するときは `island-data.mdc` の手順に加え、この JSON も更新する。

## 配信 JSON

### URL

```
https://oooopq.github.io/island-base/weather/{island-id}.json
```

例: `https://oooopq.github.io/island-base/weather/ishigaki.json`

### スキーマ（島ごと 1 ファイル）

`WeatherInfo` 互換 + `updatedAt`。`weather` / `wave` は配信層では分けない（Actions 側でマージ済みにする）。

```json
{
  "updatedAt": "2026-07-28T06:10:00+09:00",
  "temperatureCelsius": 28,
  "apparentTemperatureCelsius": 30,
  "condition": "晴れ",
  "humidityPercent": 75,
  "windSpeedKmh": 12,
  "currentWaveHeightMeters": 0.8,
  "todayMaxWaveHeightMeters": 1.2,
  "todayHourlyForecast": [],
  "weeklyForecast": []
}
```

### manifest.json（任意・運用用）

```
docs/weather/manifest.json
```

アプリの必須取得対象ではない。CI 検証・手動確認用。

## Python スクリプト

- ファイル: `scripts/fetch_weather_cache.py`（未作成）
- 依存: Python 標準ライブラリのみ
- 移植元: `IslandBase/Services/WeatherService.swift`
  - `WeatherConditionMapper`（WMO → 日本語）
  - `WeatherDateFormatter`（`7/27（月）`、`9時`）
  - hourly: 現在時刻の時以降・最大 24 件
  - marine: 今日の最大波高

## iOS アプリ改修

### 変更ファイル

| ファイル | 変更内容 |
|----------|----------|
| `WeatherService.swift` | Open-Meteo 直接呼び出しを廃止し、Pages JSON 取得に差し替え |
| `AppLegalInfo.swift` | `weatherCacheBaseURL` / `weatherCacheUpdateIntervalSeconds` を追加 |
| `IslandDetailView.swift` | 取得成功時も `isFromCache: true`（更新時刻表示のため） |

### 変更不要

- `WeatherInfo.swift` / 各天気 View
- `CacheAgeText.swift`（`fetchedAt` があれば既存ロジックで表示可能）

### キャッシュ戦略（3 層）

| 層 | 役割 | 対策 |
|----|------|------|
| GitHub Pages CDN | 静的配信 | `?h=YYYYMMDDHH`（JST 時間ブロック） |
| URLSession HTTP キャッシュ | 意図しない古さ | `cachePolicy = .reloadIgnoringLocalCacheData` |
| UserDefaults `weather_cache_v6_*` | オフライン・取得失敗 | 既存フォールバックを維持 |

Open-Meteo への直接フォールバックは入れない（コール数固定の目的と矛盾するため）。

### AppLegalInfo に追加する定数（予定）

```swift
static let weatherCacheBaseURL = "https://oooopq.github.io/island-base/weather"
static let weatherCacheUpdateIntervalSeconds = 3600
```

## 文案・審査

実装時に更新:

- `docs/privacy-policy-ja.md` / `privacy-policy.html`
- `docs/connect-app-privacy-ja.md`

変更内容: 端末から Open-Meteo へ直接通信 → 開発者が GitHub Pages で配信する天気キャッシュ（出典: Open-Meteo）を取得。

Open-Meteo CC BY 4.0 表記（`WeatherSectionView`）は維持する。

## 実装フェーズ

| Phase | 内容 | 状態 |
|-------|------|------|
| 0 | 設計書・Cursor Rules・座標 JSON | ✅ 本ドキュメント |
| 1 | `fetch_weather_cache.py` + ローカル実行 | 未着手 |
| 2 | `weather-cache.yml` + 初回 push（Pages に JSON 公開） | 未着手 |
| 3 | `WeatherService.swift` 差し替え | 未着手 |
| 4 | プライバシー文案更新 | 未着手 |
| 5 | 実機確認（オンライン / 機内モード） | 未着手 |

**Phase 1〜2 を先に完了し、Pages に JSON が載ってから Phase 3 に入ること。**

## Mac で実装を始めるとき

1. `main` を pull（本ブランチのマージ後）
2. Cursor でリポジトリを開く
3. チャットで「`.cursor/rules/weather-cache.mdc` と `docs/weather-cache-design-ja.md` に沿って Phase 1 から実装して」と指示
4. Phase 2 完了後、ブラウザで `https://oooopq.github.io/island-base/weather/ishigaki.json` を確認してからアプリ改修へ

## 採用しない案

| 案 | 理由 |
|----|------|
| 配信 JSON を `weather` / `wave` 分離 | アプリ側マージが増える |
| `?ts=updatedAt` のみでキャッシュバスト | 初回取得で使えない |
| cron `:00` JST | Open-Meteo 更新との競合 |
| 取得失敗時に Open-Meteo 直叩き | コール数がユーザー数に比例 |
| Actions 失敗時に空 JSON を commit | 壊れたデータを配信する |
