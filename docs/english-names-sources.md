# 英語固有名詞の根拠（Phase 1）

確認日: 2026-10-20

ルール:

- 公式の英語名が取れたものだけ、その表記を入れる。
- 公式の英語名がないものは、ヘボン式（長音記号なし）＋種類名（Port / Co., Ltd. など）。
- 読みや公式表記に自信がないものは `nameEnglish = nil` のまま。英語モードでも日本語を出す。
- お役立ち情報の店名・住所、ライブカメラ名、リンク名は対象外。

日本語モードの写真クレジット文字列は、組み立て後が変更前の1行と一致することを差分で確認した。

## 船会社・航空会社

| 日本語名 | 英語名 | 根拠 | 確認日 |
| --- | --- | --- | --- |
| 安栄観光株式会社 | Anei Kanko Co., Ltd. | 会社英語ページ [Anei Kanko Co., Ltd.](https://aneikankou.sakura.ne.jp/languages/company/e_cf.html)。OTTOP GTFS `translations.txt`（agency 4360002020964）も同じ | 2026-10-20 |
| 株式会社八重山観光フェリー | Yaeyama Kanko Ferry | 公式英語ページ [yaeyama.co.jp/global/en.html](https://yaeyama.co.jp/global/en.html)。OTTOP GTFS `translations.txt`（agency 6360001013190）も "Yaeyama Kanko Ferry" | 2026-10-20 |
| 福山海運株式会社 | Fukuyama Kaiun Co., Ltd. | ローマ字化（公式英語名なし）。[yonakuni-ferry.com](https://www.yonakuni-ferry.com/) と OTTOP 福山 feed に英語社名なし。OTTOP の事業者名は「合資会社福山海運」だが、アプリの日本語表示は変えていない | 2026-10-20 |
| 西表島交通株式会社 | Iriomotejima Kotsu Co., Ltd. | ローマ字化（公式英語名なし）。[yubujima.com](https://yubujima.com/) に英語社名なし | 2026-10-20 |
| 琉球エアコミューター（JALグループ） | Ryukyu Air Commuter (JAL Group) | JAL 英語 [Ryukyu Air Commuter Co., Ltd.](https://www.jal.co.jp/jp/en/dom/yakkan/240326/rac/) と [グループ会社一覧](https://www.jal.co.jp/jp/en/footer/groupcompanies/) | 2026-10-20 |
| 五島旅客船株式会社 | Goto Passenger Ship | 五島市公式観光 [Getting to Each Island](https://goto.nagasaki-tabinet.com/en/access_inside) の "Goto Passenger Ship"。会社サイトに英語社名なし | 2026-10-20 |
| 木口汽船 | Kiguchi Kisen | ローマ字化（公式英語名なし）。[kiguchi-kisen.jp](https://www.kiguchi-kisen.jp/) は日本語のみ | 2026-10-20 |
| 九州商船株式会社 | Kyushu Shosen Co., Ltd. | ローマ字化（公式英語名なし）。[kyusho.co.jp](https://kyusho.co.jp/) の英語は機械翻訳導線のみで、英文社名の掲載を確認できず | 2026-10-20 |
| 全日本空輸（ANA） | All Nippon Airways (ANA) | [ANA 英語トップ](https://www.ana.co.jp/en/jp/) の "All Nippon Airways" | 2026-10-20 |
| 東海汽船株式会社 | Tokai Kisen Co., Ltd. | [Company information](https://www.tokaikisen.co.jp/en/company/) | 2026-10-20 |
| 新中央航空 | New Central Airservice Co., Ltd. | [central-air.co.jp](https://central-air.co.jp/) フッター "© New Central Airservice Co., Ltd." | 2026-10-20 |
| 中島汽船 | Nakajima Kisen | ローマ字化（公式英語名なし）。従来の英語トグル文言と同じ。愛媛県の航路案内は日本語のみ | 2026-10-20 |
| 株式会社ごごしま | Gogoshima Co., Ltd. | ローマ字化（公式英語名なし）。[gogoshima-ferry.com](https://gogoshima-ferry.com/) に英語社名なし | 2026-10-20 |
| 新喜峰（あいほく2） | （nil・日本語のまま） | 未確認。読みを確定できる公式英語名なし | 2026-10-20 |
| 佐渡汽船株式会社 | Sado Kisen Co., Ltd. | [ABOUT SADO KISEN](https://www.sadokisen.co.jp/en/corporate/) の "Sado Kisen Co., Ltd." | 2026-10-20 |
| 四国フェリー株式会社 | Shikoku Ferry Co., Ltd. | ローマ字化（公式英語名なし）。[shikokuferry.com](https://www.shikokuferry.com/) は日本語 | 2026-10-20 |
| 小豆島豊島フェリー株式会社 | Shodoshima Teshima Ferry | 公式英語時刻表 [ENGLISH](https://www.shodoshima-ferry.co.jp/lang/en.html) のページ名 | 2026-10-20 |
| 四国汽船株式会社 | Shikoku Kisen | 公式英語航路 [Shikoku Kisen](https://shikokukisen.com/en-routes/) | 2026-10-20 |
| あけぼのマリタイム株式会社 | AKEBONO MARITIME Co.Ltd. | [akebonomaritime.com](https://www.akebonomaritime.com/) のタイトル表記 | 2026-10-20 |

中島汽船だけ `AppText.nakajimaKisen` で英語名を出していた箇所は、`FerryCompany.nameEnglish` に置き換えた。案内文（愛媛県のページを見て、電話で確認）はそのまま。

## 空港・本島側の行き先（FlightEndpoint）

日本語は短い地名のまま。英語も空港の公式短名に合わせ、"Airport" は付けない。

| 日本語名 | 英語名 | 根拠 | 確認日 |
| --- | --- | --- | --- |
| 那覇 | Naha | 那覇空港の公式英語は Naha Airport。チップは日本語と同じ短い地名 | 2026-10-20 |
| 新潟 | Niigata | 新潟空港の公式英語は Niigata Airport。同上 | 2026-10-20 |
| 羽田 | Haneda | 東京国際空港の公式英語は Haneda Airport / Tokyo International Airport (Haneda)。同上 | 2026-10-20 |
| 調布 | Chofu | 調布飛行場の公式英語は Chofu Airport。同上 | 2026-10-20 |
| 静岡 | Shizuoka | 静岡空港（富士山静岡空港）の公式英語は Shizuoka Airport。同上 | 2026-10-20 |
| 長崎 | Nagasaki | 長崎空港の公式英語は Nagasaki Airport。同上 | 2026-10-20 |
| 福岡 | Fukuoka | 福岡空港の公式英語は Fukuoka Airport。同上 | 2026-10-20 |
| 北条 | Hojo | ローマ字化（公式英語名なし）。松山側の港 | 2026-10-20 |
| 高浜 | Takahama | ローマ字化（公式英語名なし）。松山側の港 | 2026-10-20 |
| 三津浜 | Mitsuhama | ローマ字化（公式英語名なし）。松山側の港 | 2026-10-20 |

## 港

英語モードの地図ピンは英語名だけ。港の一覧と、現在地・スポットからの距離文は `Oura Port (大浦港)` のように日本語を添える。

### 八重山（OTTOP GTFS `translations.txt` の stop_name / en）

安栄観光 feed（4360002020964）と八重山観光フェリー feed（6360001013190）。確認日 2026-10-20。

| 日本語名 | 英語名 | 根拠 |
| --- | --- | --- |
| 石垣港 | Ishigaki Port | OTTOP translations.txt |
| 竹富港 | Taketomi Port | 同上 |
| 小浜港 | Kohama Port | 同上 |
| 黒島港 | Kuroshima Port | 同上 |
| 波照間港 | Hateruma Port | 同上（安栄 feed） |
| 大原港 | Ohara Port | 同上 |
| 上原港 | Uehara Port | 同上 |
| 鳩間港 | Hatoma Port | 同上 |
| 与那国港 | Yonaguni Port | ローマ字化（公式英語名なし）。福山海運の GTFS 停留所は「与那国港」ではなく「久部良港」で、英語訳もない |

### 佐渡

| 日本語名 | 英語名 | 根拠 | 確認日 |
| --- | --- | --- | --- |
| 両津港 | Ryotsu Port | [佐渡汽船英語](https://www.sadokisen.co.jp/en/) の "NIIGATA - RYOTSU ROUTE" | 2026-10-20 |
| 小木港 | Ogi Port | 同ページの "NAOETSU - OGI ROUTE"。国土交通省 [CRUISE PORT GUIDE OF JAPAN](https://www.mlit.go.jp/kankocho/cruise/list/index.html) の "Ogi Port"（Sado City） | 2026-10-20 |

### 五島（五島市・長崎県の公式英語観光）

| 日本語名 | 英語名 | 根拠 | 確認日 |
| --- | --- | --- | --- |
| 福江港 | Fukue Port | [Fukue Port Terminal](https://goto.nagasaki-tabinet.com/en/spot/61088)、[DISCOVER NAGASAKI](https://www.discover-nagasaki.com/en/featured-topics/goto_guide) | 2026-10-20 |
| 田ノ浦港 | Tanoura Port | 五島市公式 [Getting to Each Island](https://goto.nagasaki-tabinet.com/en/access_inside) | 2026-10-20 |
| 奈留港 | Naru Port | 同上、DISCOVER NAGASAKI | 2026-10-20 |
| 若松港 | Wakamatsu Port | 同上 | 2026-10-20 |
| 土井浦港 | Doinoura Port | 同上の "Doinoura" | 2026-10-20 |
| 郷ノ首港 | Gonokubi Port | 同上の "Gonokubi" | 2026-10-20 |
| 奈良尾港 | Narao Port | [Narao Port Terminal](https://www.discover-nagasaki.com/en/transit/100511) | 2026-10-20 |
| 奥浦港 | Okuura Port | ローマ字化（公式英語名なし）。木口汽船の時刻表は日本語の「奥浦」 | 2026-10-20 |

### 小豆島・直島

| 日本語名 | 英語名 | 根拠 | 確認日 |
| --- | --- | --- | --- |
| 土庄港 | Tonosho Port | [Shodoshima Teshima Ferry 英語時刻表](https://www.shodoshima-ferry.co.jp/lang/en.html) の Tonosho | 2026-10-20 |
| 唐櫃港 | Karato Port | 同上の Karato | 2026-10-20 |
| 家浦港 | Ieura Port | 同上の Ieura。四国汽船英語は "Ieura Port" | 2026-10-20 |
| 宮浦港 | Miyanoura Port | [Shikoku Kisen 英語航路](https://shikokukisen.com/en-routes/) の "Miyanoura Port" | 2026-10-20 |
| 本村港 | Honmura Port | 同ページは "Honmura"。港なので Port を付けた | 2026-10-20 |
| 犬島港 | Inujima Port | 同ページの Inujima。港なので Port を付けた | 2026-10-20 |

### 伊豆（ローマ字化）

東海汽船の英語時刻表 PDF からは、岡田・元町などの港の英語表記をこの環境では確認できなかった。すべてヘボン式＋ Port。確認日 2026-10-20。

| 日本語名 | 英語名 | 根拠 |
| --- | --- | --- |
| 岡田港 | Okata Port | ローマ字化（公式英語名なし） |
| 元町港 | Motomachi Port | ローマ字化（公式英語名なし） |
| 利島港 | Toshima Port | ローマ字化（公式英語名なし） |
| 前浜港 | Maehama Port | ローマ字化（公式英語名なし） |
| 野伏港 | Nobushi Port | ローマ字化（公式英語名なし） |
| 神津港 | Kozu Port | ローマ字化（公式英語名なし） |
| 三池港 | Miike Port | ローマ字化（公式英語名なし） |
| 阿古港 | Ako Port | ローマ字化（公式英語名なし） |
| 御蔵島港 | Mikurajima Port | ローマ字化（公式英語名なし） |
| 八重根港 | Yaene Port | ローマ字化（公式英語名なし） |
| 底土港 | Sokodo Port | ローマ字化（公式英語名なし） |

### 忽那（ローマ字化）

公式英語の港名ページは見つからなかった。読みは現地の呼び（神浦はこうのうら、元怒和はもとのうわ）。確認日 2026-10-20。

| 日本語名 | 英語名 | 根拠 |
| --- | --- | --- |
| 大浦港 | Oura Port | ローマ字化（公式英語名なし） |
| 神浦港 | Konoura Port | ローマ字化（公式英語名なし） |
| 西中港 | Nishinaka Port | ローマ字化（公式英語名なし） |
| 由良港 | Yura Port | ローマ字化（公式英語名なし） |
| 泊港 | Tomari Port | ローマ字化（公式英語名なし） |
| 睦月港 | Mutsuki Port | ローマ字化（公式英語名なし） |
| 野忽那港 | Nogutsuna Port | ローマ字化（公式英語名なし） |
| 上怒和港 | Kaminuwa Port | ローマ字化（公式英語名なし） |
| 元怒和港 | Motonuwa Port | ローマ字化（公式英語名なし） |
| 津和地港 | Tsuwaji Port | ローマ字化（公式英語名なし） |
| 二神港 | Futagami Port | ローマ字化（公式英語名なし） |
| 釣島港 | Tsurushima Port | ローマ字化（公式英語名なし） |
| 安居島港 | Aijima Port | ローマ字化（公式英語名なし） |

## 八重山 GTFS の航路名

`GTFSFerryParser` が保存する `routeName` は、港の照合に使うので日本語の `stop_name` のまま（例: `石垣港 → 竹富港`）。

英語モードの時刻表と次の便バナーは、`IslandCatalog.localizedRouteName` が **同じ `IslandPort.nameEnglish`** を引いて置き換える。別の対応表は持たない。一致しない停留所名は日本語のまま。

今回の OTTOP データで、港一覧と一致せず日本語のままになる停留所:

| 日本語の停留所 | 出どころ | 扱い |
| --- | --- | --- |
| 久部良港 | 福山海運 GTFS `stops.txt`。英語訳なし | 日本語のまま |
| 石垣港離島ターミナル | 同上。アプリの港名「石垣港」とは一致しない | 日本語のまま |

## 地域のフェリー注記

日本語の文は変えていない。英語だけ追加した。

| 地域 | 英語 |
| --- | --- |
| 八重山 | Shown from modified OTTOP public GTFS (CC BY 4.0). See Credits & sources for details. |
| 八重山・有効期限 | ` (OTTOP public data)`（日本語は `（OTTOP公開データ）` のまま） |
| 伊豆 | Check the timetable and service status on the Tokai Kisen official website. |
| 五島 | Check the timetable and service status on the official websites of Goto Passenger Ship, Kiguchi Kisen, Kyushu Shosen, and others. |
| 忽那 | Check the timetable and service status on the official websites of Nakajima Kisen, Gogoshima, and others. |
| 小豆島・直島 | Check the official websites of Shikoku Ferry, Shodoshima Teshima Ferry, Shikoku Kisen, and others. |

## 写真クレジットの地名

撮影者名・ライセンス名・Wikimedia Commons / Unsplash はそのまま。「表示時に暗色グラデーションを追加」は `PhotoCreditText.darkGradientAddedJapanese` / `darkGradientAddedEnglish`（"dark gradient added for display"）。

松山市の写真は、市の公式サイト（[まちづくり推進課](https://www.city.matsuyama.ehime.jp/shisei/kakukaichiran/matidukuribu/machizukurisuishinka.html)、2026-10-20 確認）に部署の英語名がなかった。英語は指定どおり "Photo: Matsuyama City, Community Development Division (島の英語名)"。

| 括弧内（日本語） | 英語 | 根拠 |
| --- | --- | --- |
| 石垣島・川平湾 | Ishigaki, Kabira Bay | 島名はアプリ既存の英語名。川平は JNTO の Kabira（[japan.travel 川平湾](https://www.japan.travel/tw/spot/375/) の住所表記 Kabira） |
| 竹富島 / 黒島 / 西表島 | Taketomi / Kuroshima / Iriomote | アプリ既存の島の英語名 |
| 小浜島・トゥマールビーチ | Kohama, Tumaru Beach | 島名は既存。ビーチはローマ字化（公式英語名なし） |
| 波照間島・西浜 | Hateruma, Nishihama | 島名は既存。西浜はローマ字化（公式英語名なし） |
| 鳩間島・前の浜 | Hatoma, Mae-no-hama | 島名は既存。浜はローマ字化（公式英語名なし） |
| 与那国島・東崎 | Yonaguni, Agarizaki | 島名は既存。東崎は現地読みあがりざきのローマ字化（公式英語ページは未確認） |
| 佐渡島・矢島経島のたらい舟 | Sado Island, tarai-bune at Yajima and Kyojima | 島名は既存。たらい舟は佐渡観光で一般的な tarai-bune。矢島・経島はローマ字化 |
| 堂崎天主堂 | Dozaki Church | ローマ字化＋ Church（この環境では教会の公式英語ページを開いていない） |
| 旧五輪教会 | Former Gorin Church | DISCOVER NAGASAKI の "Former Gorin Church" |
| 江上天主堂 | Egami Church | DISCOVER NAGASAKI の "Egami Church" |
| 若松大橋 | Wakamatsu Bridge | ローマ字化＋ Bridge（公式英語名なし） |
| 青砂ヶ浦教会 | Aosagaura Church | ローマ字化＋ Church（公式英語ページは未確認） |
| 伊豆大島 | Izu Oshima | 島の短い英語名は Oshima。クレジットの「伊豆大島」は Izu Oshima |
| 利島・東京 | Toshima, Tokyo | アプリ既存の島名 |
| 新島・白ママ層崖 | Niijima, Shiramama Cliff | 島名は既存。白ママはローマ字化（公式英語名なし） |
| 式根島・泊海水浴場 | Shikinejima, Tomari Beach | 島名は既存。泊はローマ字化 |
| 神津島 / 三宅島 / 御蔵島 / 八丈島 | Kozushima / Miyakejima / Mikurajima / Hachijojima | アプリ既存の島名 |
| 神津島・伊豆諸島 | Kozushima, Izu Islands | アプリ既存の島名・地域名 |
| 中島・網明海岸 | Nakajima, Amiake Coast | 島名は既存。網明は読みあみあけのローマ字化（公式英語名なし） |
| 興居島 / 興居島沖合 | Gogoshima / off Gogoshima | 島名は既存 |
| 睦月島 / 二神島 / 釣島 | Muzukijima / Futagamijima / Tsurushima | アプリ既存の島名 |
| 五島市玉之浦町・頓泊海水浴場 | Tamanoura, Goto City, Tontomari Beach | 読みは五島市公式の「頓泊（とんとまり）」。英語名はローマ字化 |
| 小豆島・香川 / 直島・香川 / 豊島・香川 / 犬島 | Shodoshima, Kagawa / Naoshima, Kagawa / Teshima, Kagawa / Inujima | アプリ既存の島名 |

## nil のままにしたもの

| 対象 | 理由 |
| --- | --- |
| 新喜峰（あいほく2） | 公式英語名なし。社名の読みを確定できなかった |
| GTFS「久部良港」「石垣港離島ターミナル」 | `IslandPort.name` と一致しない。別表は作らないので日本語のまま |

## 日本語モードで意図して変えた箇所

`FerryServiceKind.shortLabel` は「高速船 / High-Speed Boat」のように日英を連結していた。言語で切り替える指定どおり、日本語は「高速船」「大型客船（夜航）」だけ、英語は "High-Speed Boat" / "Overnight Ferry" だけになる。これ以外の日本語表示文言は変えていない。

## ビルド

この環境に Xcode はない。Xcode でのビルドは未確認。既存の Python テスト（天気キャッシュ）は 25 件成功。Swift の呼び出し漏れは、`nameEnglish` を初期値 nil 付きで足し、`language` 引数も初期値 `.japanese` にしたうえで rg で確認した。
