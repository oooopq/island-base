//
//  YaeyamaIslandProfiles.swift
//  Island Base
//
//  八重山諸島の島データ（1島 = IslandProfile 1つ）
//  新しい八重山の島を足すときは、このファイルの all 配列に追加する
//  港座標: 海上保安庁「八重山列島の港」、石垣・大原・上原は OSM ferry_terminal
//

import Foundation

enum YaeyamaIslandProfiles {
    static let all: [IslandProfile] = [
        ishigaki,
        taketomi,
        kohama,
        kuroshima,
        hateruma,
        iriomote,
        hatoma,
        yonaguni,
    ]

    // MARK: - 共有データ

    private static let yaeyamaFerry = FerryCompany(
        name: "株式会社八重山観光フェリー",
        websiteURL: "https://yaeyama.co.jp/",
        phoneNumber: "0570-013-007",
        statusPageURL: "https://yaeyama.co.jp/operation.html"
    )

    private static let aneiKanko = FerryCompany(
        name: "安栄観光株式会社",
        websiteURL: "https://aneikankou.co.jp/",
        phoneNumber: "0980-83-0055",
        statusPageURL: "https://aneikankou.co.jp/condition"
    )

    private static let fukuyamaKaiun = FerryCompany(
        name: "福山海運株式会社",
        websiteURL: "https://www.yonakuni-ferry.com/",
        phoneNumber: "0980-87-2555",
        statusPageURL: "https://www.yonakuni-ferry.com/"
    )

    private static let irimoteJyosen = FerryCompany(
        name: "西表島交通株式会社",
        websiteURL: "https://yubujima.com/",
        phoneNumber: "0980-85-5601",
        statusPageURL: "https://yubujima.com/"
    )

    private static let rac = FlightAirline(
        name: "琉球エアコミューター（JALグループ）",
        websiteURL: "https://www.jal.co.jp/dom/",
        phoneNumber: "0570-025-031",
        statusPageURL: "https://www.jal.co.jp/jp/ja/flight-status/dom/"
    )


    private static let yonaguniLineFlightSchedules: [FlightAirlineSchedule] = [
        FlightAirlineSchedule(id: "yonaguni-rac", airline: rac, trips: []),
    ]

    private static let yaeyamaYouTubeURL = "https://www.youtube.com/@YAEYAMALIVE"

    private static func yaeyamaYouTube(title: String) -> LiveCamera {
        LiveCamera(title: title, urlString: yaeyamaYouTubeURL)
    }

    // MARK: - 石垣島

    private static let ishigaki = IslandProfile(
        island: Island(id: "ishigaki", nameJapanese: "石垣島", nameEnglish: "Ishigaki", latitude: 24.432805, longitude: 124.205319),
        regionID: "yaeyama",
        ports: [IslandPort(name: "石垣港", latitude: 24.337193, longitude: 124.155485)],
        jmaMarineForecastArea: .okinawaSouth,
        backgroundAssetName: "IslandBgIshigaki",
        backgroundCredit: "Photo: Roméo A. / Unsplash（石垣島・川平湾）",
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["石垣"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry, FerryGTFSFeedCatalog.fukuyama],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "ishigaki-yaeyama",
                company: yaeyamaFerry,
                trips: []
            ),
            FerryCompanySchedule(
                id: "ishigaki-anei",
                company: aneiKanko,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "ishigaki-hospital", category: .medical, name: "沖縄県立八重山病院", phoneNumber: "0980-87-5557", address: "沖縄県石垣市真栄里584-1", websiteURL: "https://yaeyamaweb.hosp.pref.okinawa.jp/", note: "八重山の中核病院（救急対応）"),
            UsefulInfo(id: "ishigaki-convenience", category: .convenience, name: "離島ターミナル・市街地周辺", phoneNumber: nil, address: "石垣港・美崎町・730交差点付近", websiteURL: nil, note: "セブン-イレブン、ローソン、ゆうちょATMなど"),
            UsefulInfo(id: "ishigaki-tourism", category: .tourism, name: "石垣市観光交流協会", phoneNumber: "0980-82-2808", address: "沖縄県石垣市真栄里283", websiteURL: "https://www.yaeyama.or.jp/", note: "観光案内・イベント情報"),
        ],
        liveCameras: [
            LiveCamera(title: "石垣港ライブカメラ（RBC）", urlString: "https://www.youtube.com/watch?v=5jHCxMEGor0"),
        ],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム"),
        ],
        flightSchedules: yonaguniLineFlightSchedules,
        flightScheduleNote: nil,
    )

    // MARK: - 竹富島

    private static let taketomi = IslandProfile(
        island: Island(id: "taketomi", nameJapanese: "竹富島", nameEnglish: "Taketomi", latitude: 24.325064, longitude: 124.088064),
        regionID: "yaeyama",
        ports: [IslandPort(name: "竹富港", latitude: 24.335000, longitude: 124.095556)],
        jmaMarineForecastArea: .okinawaSouth,
        backgroundAssetName: "IslandBgTaketomi",
        backgroundCredit: "Photo: Hiroko Yoshii / Unsplash（竹富島）",
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["竹富"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "taketomi-yaeyama",
                company: yaeyamaFerry,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "taketomi-clinic", category: .medical, name: "竹富町立竹富診療所", phoneNumber: "0980-85-2132", address: "沖縄県竹富町竹富323", websiteURL: "https://taketomi.jadecom.or.jp/", note: "診療時間は公式サイトで要確認"),
            UsefulInfo(id: "taketomi-convenience", category: .convenience, name: "竹富港・集落周辺", phoneNumber: nil, address: "竹富港から徒歩圏内", websiteURL: nil, note: "コンビニ・ATMは集落内に少数"),
            UsefulInfo(id: "taketomi-tourism", category: .tourism, name: "竹富町観光協会", phoneNumber: "0980-85-2441", address: "沖縄県竹富町竹富", websiteURL: "https://www.taketomijima.jp/", note: "水牛車・サイクル観光の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム（竹富島周辺）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 小浜島

    private static let kohama = IslandProfile(
        island: Island(id: "kohama", nameJapanese: "小浜島", nameEnglish: "Kohama", latitude: 24.341111, longitude: 123.980833),
        regionID: "yaeyama",
        // 港座標: 海上保安庁「八重山列島の港」小浜（地方港湾）24°20′42″N 123°59′35″E。細崎漁港ではない
        ports: [IslandPort(name: "小浜港", latitude: 24.345000, longitude: 123.993056)],
        jmaMarineForecastArea: .okinawaSouth,
        backgroundAssetName: "IslandBgKohama",
        backgroundCredit: "Photo: Paipateroma / Wikimedia Commons（小浜島・トゥマールビーチ）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["小浜"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "kohama-yaeyama",
                company: yaeyamaFerry,
                trips: []
            ),
            FerryCompanySchedule(
                id: "kohama-anei",
                company: aneiKanko,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "kohama-clinic", category: .medical, name: "県立小浜診療所", phoneNumber: "0980-85-3247", address: "沖縄県竹富町小浜30", websiteURL: "https://yaeyamaweb.hosp.pref.okinawa.jp/information/shinryou/kohama/", note: "平日診療（詳細は要確認）"),
            UsefulInfo(id: "kohama-convenience", category: .convenience, name: "小浜港・集落周辺", phoneNumber: nil, address: "小浜港から徒歩圏内", websiteURL: nil, note: "港周辺に店舗あり。コンビニは少なめ"),
            UsefulInfo(id: "kohama-tourism", category: .tourism, name: "竹富町観光協会（小浜島）", phoneNumber: "0980-85-2441", address: "沖縄県竹富町小浜", websiteURL: "https://www.taketomijima.jp/", note: "大岳展望台・ちゅらさんの島"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム（小浜島周辺）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 黒島

    private static let kuroshima = IslandProfile(
        island: Island(id: "kuroshima", nameJapanese: "黒島", nameEnglish: "Kuroshima", latitude: 24.237716, longitude: 124.010266),
        regionID: "yaeyama",
        ports: [IslandPort(name: "黒島港", latitude: 24.254167, longitude: 124.000889)],
        jmaMarineForecastArea: .okinawaSouth,
        backgroundAssetName: "IslandBgKuroshima",
        backgroundCredit: "Photo: Tomoyuki Shidara（黒島）",
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["黒島"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "kuroshima-anei",
                company: aneiKanko,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "kuroshima-clinic", category: .medical, name: "竹富町立黒島診療所", phoneNumber: "0980-85-4114", address: "沖縄県竹富町黒島1473-1", websiteURL: "https://kuroshima.jadecom.or.jp/", note: "診療時間は公式サイトで要確認"),
            UsefulInfo(id: "kuroshima-convenience", category: .convenience, name: "黒島港周辺", phoneNumber: nil, address: "黒島港・集落", websiteURL: nil, note: "店舗は限られます。現金の用意を"),
            UsefulInfo(id: "kuroshima-tourism", category: .tourism, name: "黒島観光案内（竹富町）", phoneNumber: "0980-85-2441", address: "竹富町役場観光課", websiteURL: "https://www.taketomijima.jp/", note: "黒島は竹富町に属します"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム（黒島周辺）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 波照間島

    private static let hateruma = IslandProfile(
        island: Island(id: "hateruma", nameJapanese: "波照間島", nameEnglish: "Hateruma", latitude: 24.058487, longitude: 123.782328),
        regionID: "yaeyama",
        ports: [IslandPort(name: "波照間港", latitude: 24.067778, longitude: 123.766111)],
        jmaMarineForecastArea: .okinawaSouth,
        backgroundAssetName: "IslandBgHateruma",
        backgroundCredit: "Photo: Tomoyuki Shidara（波照間島・西浜）",
        placeSearchRadiusMeters: 10_000,
        routeKeywords: ["波照間"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "hateruma-yaeyama",
                company: yaeyamaFerry,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "hateruma-clinic", category: .medical, name: "県立八重山病院附属 波照間診療所", phoneNumber: "0980-85-8402", address: "沖縄県竹富町波照間2750-1", websiteURL: "https://yaeyamaweb.hosp.pref.okinawa.jp/information/shinryou/hateruma/", note: "診療時間は公式サイトで要確認"),
            UsefulInfo(id: "hateruma-convenience", category: .convenience, name: "港・集落周辺の店舗", phoneNumber: nil, address: "波照間港付近", websiteURL: nil, note: "コンビニ・ATMは少なめです"),
            UsefulInfo(id: "hateruma-tourism", category: .tourism, name: "波照間島観光案内", phoneNumber: "0980-85-8767", address: "沖縄県竹富町波照間", websiteURL: "https://painusima.com/category/sima/haterumajima/", note: "最南端の碑・星空観測など"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム（波照間方面）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 西表島

    private static let iriomote = IslandProfile(
        island: Island(id: "iriomote", nameJapanese: "西表島", nameEnglish: "Iriomote", latitude: 24.335989, longitude: 123.814737),
        regionID: "yaeyama",
        ports: [
            IslandPort(name: "大原港", latitude: 24.271895, longitude: 123.884104),
            IslandPort(name: "上原港", latitude: 24.417955, longitude: 123.799790),
        ],
        jmaMarineForecastArea: .okinawaSouth,
        backgroundAssetName: "IslandBgIriomote",
        backgroundCredit: "Photo: Wataru Sato / Unsplash（西表島）",
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["大原", "上原", "西表", "由布"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "iriomote-yaeyama",
                company: yaeyamaFerry,
                trips: []
            ),
            FerryCompanySchedule(
                id: "iriomote-jyosen",
                company: irimoteJyosen,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "iriomote-clinic-west", category: .medical, name: "県立八重山病院附属 西表西部診療所", phoneNumber: "0980-85-6268", address: "沖縄県竹富町西表694", websiteURL: "https://yaeyamaweb.hosp.pref.okinawa.jp/information/shinryou/seibu/", note: "西部地区・祖納にある診療所。診療時間は公式サイトで要確認"),
            UsefulInfo(id: "iriomote-clinic-east", category: .medical, name: "県立八重山病院附属 大原診療所", phoneNumber: "0980-85-5516", address: "沖縄県竹富町南風見201-131", websiteURL: "https://yaeyamaweb.hosp.pref.okinawa.jp/information/shinryou/oohara/", note: "大原港近くの診療所。診療時間は公式サイトで要確認"),
            UsefulInfo(id: "iriomote-convenience", category: .convenience, name: "大原・上原の港周辺", phoneNumber: nil, address: "各港の集落", websiteURL: nil, note: "大原港・上原港付近に店舗・ATM"),
            UsefulInfo(id: "iriomote-tourism", category: .tourism, name: "竹富町観光協会（西表島）", phoneNumber: "0980-85-6185", address: "沖縄県竹富町大原", websiteURL: "https://painusima.com/modelcourse_iriomote/", note: "カヤック・トレッキング等の案内"),
        ],
        liveCameras: [
            LiveCamera(title: "西表島ライブカメラ（ヤシガニNET）", urlString: "https://www.youtube.com/@iriomote1956"),
        ],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム（西表島周辺）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 鳩間島

    private static let hatoma = IslandProfile(
        // 島中心: OSM relation 4858189（鳩間島）の out center
        island: Island(id: "hatoma", nameJapanese: "鳩間島", nameEnglish: "Hatoma", latitude: 24.472156, longitude: 123.820048),
        regionID: "yaeyama",
        // 港座標: 海上保安庁「八重山列島の港」鳩間（地方港湾）24°28′03″N 123°49′16″E。島の南側
        ports: [IslandPort(name: "鳩間港", latitude: 24.467500, longitude: 123.821111)],
        jmaMarineForecastArea: .okinawaSouth,
        backgroundAssetName: "IslandBgHatoma",
        backgroundCredit: "Photo: Paipateroma / Wikimedia Commons（鳩間島・前の浜）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 3_000,
        routeKeywords: ["鳩間"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "hatoma-anei",
                company: aneiKanko,
                trips: []
            ),
            FerryCompanySchedule(
                id: "hatoma-yaeyama",
                company: yaeyamaFerry,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "hatoma-clinic", category: .medical, name: "常設診療所なし（西表・石垣へ）", phoneNumber: "0980-85-6268", address: "西表西部診療所（竹富町西表694）", websiteURL: "https://yaeyamaweb.hosp.pref.okinawa.jp/information/shinryou/seibu/", note: "鳩間島に常設診療所はありません。急病時は119番または関係機関へ連絡し、西表・石垣への移動を含め案内に従ってください"),
            UsefulInfo(id: "hatoma-convenience", category: .convenience, name: "鳩間港・集落周辺", phoneNumber: nil, address: "鳩間港付近", websiteURL: nil, note: "店舗は限られます。現金の用意を"),
            UsefulInfo(id: "hatoma-tourism", category: .tourism, name: "竹富町観光協会（鳩間島）", phoneNumber: "0980-85-2441", address: "沖縄県竹富町鳩間", websiteURL: "https://painusima.com/category/sima/hatomajima/", note: "西表島の北。上原航路の経由便のため、上原欠航時は鳩間便も欠航します"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム（鳩間島周辺）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 与那国島

    private static let yonaguni = IslandProfile(
        island: Island(id: "yonaguni", nameJapanese: "与那国島", nameEnglish: "Yonaguni", latitude: 24.455366, longitude: 122.988942),
        regionID: "yaeyama",
        ports: [IslandPort(name: "与那国港", latitude: 24.451944, longitude: 122.940000)],
        jmaMarineForecastArea: .eastChinaSouth, // 与那国港付近は JMA 細分海域ポリゴン外のため 6010（東シナ海南部）
        backgroundAssetName: "IslandBgYonaguni",
        backgroundCredit: "Photo: Metatron / Wikimedia Commons（与那国島・東崎）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 10_000,
        routeKeywords: ["与那国"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.fukuyama, FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "yonaguni-fukuyama",
                company: fukuyamaKaiun,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "yonaguni-clinic", category: .medical, name: "与那国町診療所", phoneNumber: "0980-87-2250", address: "沖縄県与那国町与那国125-1", websiteURL: "https://yonaguni-clinic.jp/", note: "診療時間・時間外対応は公式サイトで要確認"),
            UsefulInfo(id: "yonaguni-convenience", category: .convenience, name: "久部良港・集落周辺", phoneNumber: nil, address: "与那国港付近", websiteURL: nil, note: "店舗は限られます"),
            UsefulInfo(id: "yonaguni-tourism", category: .tourism, name: "与那国町観光協会", phoneNumber: "0980-87-2441", address: "沖縄県与那国町与那国", websiteURL: "https://welcome-yonaguni.jp/", note: "最西端の碑・ダイビング等"),
        ],
        liveCameras: [
            // YouTube を先に置く（海上保安庁ページは iPhone で真っ白になりやすい）
            LiveCamera(title: "八重山リアルタイム（ライブ配信）", urlString: "https://www.youtube.com/@YAEYAMALIVE/live"),
            LiveCamera(title: "西埼灯台（海上保安庁・公式ページ）", urlString: "https://www6.kaiho.mlit.go.jp/11kanku/ishigaki/irisaki_lt/livecamera/index.html"),
        ],
        youtubeRelatedLinks: [
            yaeyamaYouTube(title: "八重山リアルタイム"),
        ],
        liveCameraFootnote: "※ 西埼灯台（海上保安庁）の公式ページは、iPhone では真っ白・非表示になることがあります。上の「八重山リアルタイム」リンクをご利用ください。",
        liveCameraFootnoteEnglish: "※ The Japan Coast Guard Irizaki Lighthouse page may appear blank on iPhone. Please use the Yaeyama Realtime YouTube live link above.",
        flightSchedules: yonaguniLineFlightSchedules,
        flightScheduleNote: nil,
    )
}
