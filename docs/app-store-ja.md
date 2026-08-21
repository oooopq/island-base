# App Store 掲載文案（Island Base）

App Store Connect にそのままコピーして使える文案です。

最終更新: 2026年8月21日  
（申請前評価レポート反映：説明文と実機能の一致・審査メモ強化）

---

## アプリ名

Island Base

## サブタイトル（30文字以内）

離島の天気・船便・店舗情報

## プロモーション用テキスト（170文字以内・任意）

八重山・伊豆・五島・忽那・佐渡島・小豆島直島の離島向けに、天気・波の高さ・役立つ連絡先・店舗をまとめて確認。船便・航空便は各社公式サイトへ（八重山は公開ダイヤをアプリ内表示）。欠航・遅延は必ず公式で最新確認を。

## 説明文

Island Base は、日本の離島を訪れる方のための現地情報アプリです。八重山諸島・伊豆諸島・五島列島・忽那諸島・佐渡島・小豆島・直島諸島の各島について、旅行の計画と当日の判断に役立つ情報を1つにまとめています。

【主な機能】
・天気（現在・1時間ごと・1週間予報）と波の高さ（アプリ内表示。GitHub Pages キャッシュ／出典 Open-Meteo。一部は気象庁 seamless モデル）
・気象庁「海上警報・予報」へのリンク（島ごとの細分海域）
・船便・航空便：各運航会社・航空会社の公式サイトへのリンク（運行状況・ダイヤ）
・八重山諸島の船便のみ：沖縄の公開データ（GTFS）に基づくダイヤをアプリ内表示（他地域は公式リンクのみ）
・病院・コンビニ・観光案内などの役立つ連絡先
・島付近の飲食店・宿泊・商店など（Apple マップ連携・Google マップリンク）
・ライブカメラ・関連リンク（島により異なります。アプリ内埋め込みではなく外部ブラウザで開きます）
・現在地の表示（使用中のみ・任意・端末内）
・写真メモ（時刻表などの撮影・端末内保存）
・日本語 / 英語の表示切替

【対象地域】
・八重山諸島（石垣島、竹富島、小浜島、黒島、波照間島、西表島、鳩間島、与那国島）
・伊豆諸島（大島、利島、新島、式根島、神津島、三宅島、御蔵島、八丈島）
・五島列島（福江島、久賀島、奈留島、若松島、中通島）
・忽那諸島（中島、興居島、睦月島、野忽那島、怒和島、津和地島、二神島、釣島、安居島）
・佐渡島
・小豆島・直島諸島（小豆島、直島、豊島、犬島）

【重要なお知らせ】
八重山以外の地域では、船便・航空便の発着時刻はアプリ内に表示しません。各社の公式サイトで最新のダイヤ・運航状況をご確認ください。八重山の船便ダイヤも公開データに基づく参考情報であり、欠航・遅延・運休はリアルタイムで反映されません。

天気・波の高さも参考情報です。海上・気象の安全を保証するものではありません。WBGT・熱中症指数など未実装の指標は扱いません。

店舗・施設情報は Apple マップの検索結果を表示しており、内容・営業状況の正確性は保証しません。

【データの出典（例）】
・天気・波の高さ: Open-Meteo（一部 jma_seamless）。端末は当方の GitHub Pages キャッシュを取得
・海上予報: 気象庁「海上警報・予報」（リンク）
・八重山フェリー: OTTOP 公開 GTFS（（有）安栄観光・八重山観光フェリー（株）・福山海運）を改変して表示（CC BY 4.0）
・その他船便・航空便: 各社公式サイトへのリンク
・店舗: Apple マップ（MapKit）、Google マップ（リンク）

【外部リンクについて】
予約サイト、運航状況ページ、YouTube、電話（tel:）など外部サービスへ移動するリンクがあります。リンク先の内容・料金・可用性について、開発者は責任を負いません。

【位置情報について】
現在地は、選択した島の詳細画面の地図上に表示する目的でのみ、使用中に端末内で利用します。開発者のサーバーへ送信しません。

【写真メモについて】
撮影または選んだ写真は端末内のみに保存し、開発者のサーバーへ送信しません。

---

お問い合わせ: opaquu@gmail.com

プライバシーポリシー: https://oooopq.github.io/island-base/privacy-policy.html

利用規約: https://oooopq.github.io/island-base/terms-of-service.html

## キーワード（100文字以内・カンマ区切り）

離島,八重山,石垣,伊豆諸島,五島,忽那,佐渡,小豆島,直島,フェリー,高速船,船便,天気,波,航空便,運航状況,観光,旅行

## カテゴリ（提案）

旅行

## 年齢制限

4+（コンテンツに制限なし）

## App Store Connect「App のプライバシー」回答の目安

詳細な手順は [`connect-app-privacy-ja.md`](./connect-app-privacy-ja.md) を参照。

| データ種別 | 収集（開発者へ送信） | 追跡 | 備考 |
|---|---|---|---|
| 位置情報（正確） | いいえ | いいえ | 端末内マップ表示のみ |
| 写真または動画 | いいえ | いいえ | 写真メモは端末内のみ。開発者サーバーへ送らない |
| 連絡先・識別子・購入履歴等 | いいえ | いいえ | アカウント機能なし |
| 診断・クラッシュデータ | いいえ | いいえ | 未実装（2026年8月時点） |

※ Xcode の `PrivacyInfo.xcprivacy` は Tracking なし・UserDefaults（CA92.1）のみ。
※ カメラ／フォトライブラリ権限は Info.plist の用途説明と一致させてください。
※ Connect 申告は実装どおり「位置情報・写真は収集しない／トラッキングなし」。ズレると Guideline 5.1.1 / 5.1.2 のリスク。

## 審査用メモ（App Review Information・推奨）

Connect の Review Notes にそのまま貼ってください（Guideline 2.1 / 4.2 / 5.2 対策）。

```
Island Base is a reference app for Japan’s remote islands.

In-app features (not a link directory):
• Weather and wave height are shown in-app (GitHub Pages cache; source: Open-Meteo).
• Yaeyama ferry timetables only are shown in-app from OTTOP public GTFS (CC BY 4.0; adapted).
• Place search (MapKit), useful contacts, and on-device photo notes.

Links / schedules:
• Outside Yaeyama, ferry/flight info is official-site links only (no in-app timetables).
• Live cameras and related pages open in the external browser (not embedded). Public streams / official pages only.
• On Yonaguni, the Japan Coast Guard lighthouse camera page may appear blank on iPhone; please use the YouTube live link above it.

Privacy:
• Location and photo notes stay on-device; we do not send them to our servers. No account / no tracking.

Data sources (also in-app ℹ️ Credits): Open-Meteo; JMA marine forecast links; OTTOP GTFS (CC BY 4.0).
Privacy Policy: https://oooopq.github.io/island-base/privacy-policy.html
Support: opaquu@gmail.com
```

日本語版（社内控え・任意）:

```
Island Base は離島向けの参考情報アプリです。
・天気・波の高さはアプリ内表示（GitHub Pages キャッシュ／出典 Open-Meteo）。
・八重山の船便のみ、OTTOP の GTFS（CC BY 4.0）を改変してアプリ内に表示します。
・その他地域の船便・航空便は各社公式サイトへのリンクのみ（アプリ内に時刻表なし）。
・ライブカメラは公開配信・公式ページへの外部ブラウザリンクです（埋め込みなし）。
・与那国の海上保安庁灯台カメラは iPhone で真っ白になることがあります。上の YouTube ライブをご確認ください。
・位置情報・写真メモは端末内のみ。開発者サーバーへ送信しません。トラッキングなし。
出典はアプリ内クレジット（ℹ️）および上記ポリシー URL を参照してください。
```

## スクリーンショット用キャプション（任意）

主要導線（地図 → 島一覧 → 天気 / ダイヤ / 店舗）で撮影。実画面と異なる加工はしない（Guideline 2.3.3）。

1. 地域を選んで離島へ — 地図とカバー写真から
2. 天気と波の高さ — 出航前の参考に（アプリ内表示）
3. 八重山の船便ダイヤ — OTTOP 公開 GTFS（CC BY 4.0・アプリ内表示）
4. その他の地域 — 各社公式サイトへのリンク
5. 病院・港・観光 — 現地で役立つ連絡先

※ 英語モードのスクショを使う場合、島名・施設名・一部注記に日本語が残ることがあります（全面バイリンガルではありません）。