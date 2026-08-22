# App Store Connect「App のプライバシー」入力手順（Island Base）

最終更新: 2026年8月21日

本アプリの実装（2026年8月時点）に合わせた申告の目安です。Connect の画面文言は Apple の更新で変わることがあります。

**明日の転記用確定稿:** [`connect-submit-copy-ja.md`](./connect-submit-copy-ja.md)

評価レポート（2026-08-21）: 位置情報・写真は「収集しない」、トラッキング「なし」と実装どおり申告すること。ズレると Guideline 5.1.1 / 5.1.2。

---

## 前提

- **開発者のサーバーへ個人データを送らない**（アカウントなし、Analytics なし、広告 SDK なし）
- 位置情報・写真は **端末内** でのみ利用
- **天気** — 利用者の端末は当方が GitHub Pages で配信する天気キャッシュ JSON を取得（データ出典は Open-Meteo。端末から Open-Meteo へは直接通信しません）
- **店舗・GTFS** — 端末から Apple MapKit や公開 GTFS 等へ直接通信（IP 等が各社に届く可能性はあるが、当方が「収集」するわけではない）
- **写真選択** — `PhotosPicker`（PHPicker）。フォトライブラリ全体の許可キー（`NSPhotoLibraryUsageDescription`）は使わない

---

## 手順の流れ

1. App Store Connect → 対象アプリ → **App のプライバシー**
2. **データの収集** — 「いいえ、収集するデータタイプはありません」を選ぶ
3. **データの追跡** — **いいえ**（`PrivacyInfo.xcprivacy` で `NSPrivacyTracking` = false）
4. 第三者 SDK でデータ収集を行う項目がないことを確認（Firebase 等なし）

---

## データ種別ごとの回答目安

Connect で「収集するデータタイプ」を選ぶ形式の場合、**当方がサーバーに保存・紐づけしない**ため、次のように整理します。

| データ | 開発者が収集するか | 追跡か | 補足 |
|---|---|---|---|
| 位置情報（正確） | **いいえ** | いいえ | 島詳細の地図に現在地を出すだけ。端末内。拒否可 |
| 写真・動画 | **いいえ** | いいえ | 写真メモはサンドボックス内のみ。システムピッカーで選択 |
| 連絡先 | いいえ | いいえ | 未使用 |
| 識別子（メール等） | いいえ | いいえ | 未使用 |
| 使用状況・診断 | いいえ | いいえ | クラッシュレポーター未実装 |

**注意:** 「収集しない」とは **開発者がユーザーデータを取得してサーバーに保持しない** という意味です。権限ダイアログ（位置・カメラ）が出ても、Connect では収集しないと答えるのが正しいです。GitHub Pages・Apple MapKit 等への通信は、Apple の質問では別カテゴリ（第三者処理）として説明されることがあります。不明な選択肢は「データを収集しない」に近い方を選び、審査メモで補足してもよいです。

---

## 権限（Info.plist）との対応

| 権限 | 用途 | プライバシー申告との関係 |
|---|---|---|
| 使用中の位置情報 | 島詳細地図の現在地 | 端末内のみ → 開発者収集なし |
| カメラ | 写真メモの撮影 | 端末内保存のみ |
| フォトライブラリ全体 | **要求しない** | PHPicker のため `NSPhotoLibraryUsageDescription` なし |

日本語端末向け文言は `ja.lproj/InfoPlist.strings`、英語は `en.lproj/InfoPlist.strings`。

---

## 提出前チェック

- [x] `PrivacyInfo.xcprivacy` がビルドに含まれている
- [ ] プライバシーポリシー URL: https://oooopq.github.io/island-base/privacy-policy.html がブラウザで開く（英語節あり）
- [ ] ポリシー本文が位置情報・写真メモ・第三者通信（GitHub Pages 天気キャッシュ含む）を説明している
- [ ] アプリ内 ℹ️ から同じ URL が開ける
- [ ] Connect 申告が「収集データなし / 追跡なし」

---

## 審査で聞かれたときの短文（英語例・任意）

```
We do not collect personal data on our servers. Location is used on-device only for the map on the island detail screen. Photo notes stay in the app sandbox. The camera permission is for capture; choosing an existing photo uses the system Photos picker (no full library access). Weather is fetched from our GitHub Pages cache (sourced from Open-Meteo; the device does not call Open-Meteo directly). Ferry GTFS and place search are fetched from third-party APIs by the device.
```
