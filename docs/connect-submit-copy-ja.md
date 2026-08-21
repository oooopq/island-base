# App Store Connect 転記用（明日の申請・確定稿）

最終更新: 2026年8月21日

Connect に **コピーして貼るだけ** の文面です。スクショ撮影と実機スモークはこのファイルの対象外です。

公開ページ（ブラウザで開けること）:

- プライバシーポリシー: https://oooopq.github.io/island-base/privacy-policy.html
- 利用規約: https://oooopq.github.io/island-base/terms-of-service.html
- サポート URL: https://oooopq.github.io/island-base/

**禁止:** `opaquu.github.io` は使わない（404 → リジェクト）。

---

## 1. プライバシーポリシー URL

App Store Connect → アプリ情報 → プライバシーポリシー URL:

```
https://oooopq.github.io/island-base/privacy-policy.html
```

利用規約 URL（任意）:

```
https://oooopq.github.io/island-base/terms-of-service.html
```

サポート URL:

```
https://oooopq.github.io/island-base/
```

サポートメール（App Review Information）:

```
opaquu@gmail.com
```

---

## 2. App のプライバシー（申告）

実装: 開発者サーバーへ個人データを送らない。アカウントなし。広告・Analytics・IDFA なし。位置情報と写真メモは端末内のみ。`PrivacyInfo.xcprivacy` は Tracking = false、収集データタイプなし。

**回答（このとおり）:**

1. この App からデータを収集しますか → **いいえ**（「収集するデータタイプはありません」）
2. データ収集の画面が種別選択の場合 → 位置情報・写真・連絡先・識別子・診断を **選ばない**
3. 追跡しますか → **いいえ**
4. 第三者 SDK の申告 → 該当なし（Firebase / 広告 SDK なし）

| 聞かれた項目 | 答え |
|---|---|
| 位置情報 | 収集しない（端末内マップのみ） |
| 写真 / 動画 | 収集しない（写真メモは端末内。システム写真ピッカーで選択、フルアクセスなし） |
| 追跡 | しない |

ズレると Guideline 5.1.1 / 5.1.2 です。権限ダイアログがあることと「収集する」は別です。

詳細手順: [`connect-app-privacy-ja.md`](./connect-app-privacy-ja.md)

---

## 3. 説明文など（機能と一致）

アプリ名: `Island Base`  
サブタイトル: `離島の天気・船便・店舗情報`  
カテゴリ: 旅行  
年齢: 4+

プロモーション用テキスト:

```
八重山・伊豆・五島・忽那・佐渡島・小豆島直島の離島向けに、天気・波の高さ・役立つ連絡先・店舗をまとめて確認。船便・航空便は各社公式サイトへ（八重山は公開ダイヤをアプリ内表示）。欠航・遅延は必ず公式で最新確認を。
```

説明文:

```
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
```

キーワード:

```
離島,八重山,石垣,伊豆諸島,五島,忽那,佐渡,小豆島,直島,フェリー,高速船,船便,天気,波,航空便,運航状況,観光,旅行
```

書いてはいけないこと:

- 「代表ダイヤをアプリ内表示」（実装していない）
- WBGT・熱中症指数を機能として書く
- 八重山以外でも時刻表をアプリ内表示すると書く
- 古い `opaquu.github.io` URL

---

## 4. 審査用メモ（App Review Information）

英語を Connect に貼る（審査員向け）。デモアカウントは不要（アカウント機能なし）。輸出コンプライアンスは Info.plist で `ITSAppUsesNonExemptEncryption = NO`。

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
• Location (When In Use) is on-device for the island map only; we do not send it to our servers.
• Photo notes: camera permission for capture; the system Photos picker (PHPicker) to choose an existing photo — no full Photo Library access. Photos stay on-device.
• No account, no tracking, no advertising SDK.

Data sources (also in-app ℹ️ Credits): Open-Meteo; JMA marine forecast links; OTTOP GTFS (CC BY 4.0).
Privacy Policy: https://oooopq.github.io/island-base/privacy-policy.html
Support: opaquu@gmail.com
```

---

## このファイルでやらないこと

- スクリーンショット撮影・登録
- 実機スモークテスト
