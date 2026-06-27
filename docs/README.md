# Island Now — リリース用ドキュメント

App Store 公開と法的表記用の文案です。

| ファイル | 用途 |
|---|---|
| [app-store-ja.md](./app-store-ja.md) | App Store Connect の説明文・キーワード等 |
| [privacy-policy-ja.md](./privacy-policy-ja.md) | プライバシーポリシー（原稿・Markdown） |
| [terms-of-service-ja.md](./terms-of-service-ja.md) | 利用規約（原稿・Markdown） |
| [privacy-policy.html](./privacy-policy.html) | プライバシーポリシー（Web 公開用 HTML） |
| [terms-of-service.html](./terms-of-service.html) | 利用規約（Web 公開用 HTML） |
| [index.html](./index.html) | GitHub Pages トップ |

## 公開 URL（GitHub Pages）

リポジトリの **Settings → Pages → Source: Deploy from branch → /docs** で公開すると、以下の URL になります（リポジトリ名が `island-now` の場合）:

- トップ: https://opaquu.github.io/island-now/
- プライバシーポリシー: https://opaquu.github.io/island-now/privacy-policy.html
- 利用規約: https://opaquu.github.io/island-now/terms-of-service.html

お問い合わせ: opaquu@gmail.com

アプリ内の `AppLegalInfo.swift` も上記 URL を参照しています。リポジトリ名やユーザー名を変えた場合は、HTML 公開後に `AppLegalInfo` と App Store Connect の URL を合わせて更新してください。

## 公開前チェックリスト

1. GitHub Pages を有効化し、上記 URL がブラウザで開けることを確認
2. App Store Connect に以下を入力
   - 説明文・キーワード → `app-store-ja.md`
   - プライバシーポリシー URL
   - 利用規約 URL（任意だが推奨）
   - App のプライバシー（データ収集の申告）
3. 実機で ℹ️ → クレジット・出典、規約リンク、天気セクションの Open-Meteo リンクを確認
4. 位置情報ダイアログの文言を確認（「選択した島の地図上に、あなたの現在地を表示するために使います。」）

## App Store Connect「App のプライバシー」

2026年6月時点のアプリ実装に基づく目安:

- **データを収集しない** に近い申告が可能（サーバーへの個人情報送信なし）
- 位置情報は端末内のみ → 「データにリンクされない」「追跡に使用しない」
- 第三者 SDK（Analytics 等）を追加した場合は **必ず再確認**

## 免責

これらの文案はテンプレートです。個別の事業形態・地域・機能追加により要件が変わる場合があります。
