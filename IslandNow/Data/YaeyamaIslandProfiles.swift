//
//  YaeyamaIslandProfiles.swift
//  Island Now
//
//  八重山諸島の島データ（1島 = IslandProfile 1つ）
//  新しい八重山の島を足すときは、このファイルの all 配列に追加する
//

import Foundation

enum YaeyamaIslandProfiles {
    static let all: [IslandProfile] = [
        ishigaki,
        taketomi,
        kuroshima,
        hateruma,
        iriomote,
        yonaguni,
    ]

    // MARK: - 共有データ

    private static let yaeyamaFerry = FerryCompany(
        name: "株式会社八重山観光フェリー",
        websiteURL: "https://yaeyama.co.jp/",
        phoneNumber: "0570-013-007"
    )

    private static let aneiKanko = FerryCompany(
        name: "安栄観光株式会社",
        websiteURL: "https://aneikankou.co.jp/",
        phoneNumber: "0980-83-0055"
    )

    private static let irimoteJyosen = FerryCompany(
        name: "西表島交通株式会社",
        websiteURL: "https://iriomote.com/",
        phoneNumber: "0980-85-5601"
    )

    private static let rac = FlightAirline(
        name: "琉球エアコミューター（JALグループ）",
        websiteURL: "https://www.jal.co.jp/dom/",
        phoneNumber: "0570-025-031"
    )

    private static let yonaguniLineFlights: [FlightTrip] = [
        FlightTrip(id: "rac721", flightNumber: "RAC721", routeName: "那覇 → 与那国", departureTime: "07:15", arrivalTime: "08:30"),
        FlightTrip(id: "rac727", flightNumber: "RAC727", routeName: "那覇 → 与那国", departureTime: "14:55", arrivalTime: "16:10"),
        FlightTrip(id: "rac724", flightNumber: "RAC724", routeName: "与那国 → 那覇", departureTime: "11:25", arrivalTime: "12:45"),
        FlightTrip(id: "rac728", flightNumber: "RAC728", routeName: "与那国 → 那覇", departureTime: "18:50", arrivalTime: "20:10"),
        FlightTrip(id: "rac741", flightNumber: "RAC741", routeName: "石垣 → 与那国", departureTime: "10:05", arrivalTime: "10:35"),
        FlightTrip(id: "rac743", flightNumber: "RAC743", routeName: "石垣 → 与那国", departureTime: "12:35", arrivalTime: "13:05"),
        FlightTrip(id: "rac747", flightNumber: "RAC747", routeName: "石垣 → 与那国", departureTime: "17:50", arrivalTime: "18:20"),
        FlightTrip(id: "rac742", flightNumber: "RAC742", routeName: "与那国 → 石垣", departureTime: "09:05", arrivalTime: "09:35"),
        FlightTrip(id: "rac744", flightNumber: "RAC744", routeName: "与那国 → 石垣", departureTime: "13:40", arrivalTime: "14:10"),
        FlightTrip(id: "rac746", flightNumber: "RAC746", routeName: "与那国 → 石垣", departureTime: "16:50", arrivalTime: "17:20"),
    ]

    private static let yonaguniLineFlightSchedules: [FlightAirlineSchedule] = [
        FlightAirlineSchedule(id: "yonaguni-rac", airline: rac, trips: yonaguniLineFlights),
    ]

    private static let flightScheduleNote = "2026年夏ダイヤ時点。季節により変更があります。"

    // MARK: - 石垣島

    private static let ishigaki = IslandProfile(
        island: Island(id: "ishigaki", nameJapanese: "石垣島", nameEnglish: "Ishigaki", latitude: 24.3444, longitude: 124.1572),
        regionID: "yaeyama",
        port: IslandPort(name: "石垣港", latitude: 24.3397, longitude: 124.1557),
        backgroundAssetName: "IslandBgIshigaki",
        backgroundCredit: "Photo: Vladimir Haltakov / Unsplash",
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["石垣"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry, FerryGTFSFeedCatalog.fukuyama],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "ishigaki-yaeyama",
                company: yaeyamaFerry,
                trips: [
                    FerryTrip(id: "1", routeName: "石垣 → 竹富", departureTime: "08:00", arrivalTime: "08:10"),
                    FerryTrip(id: "2", routeName: "石垣 → 西表", departureTime: "09:30", arrivalTime: "10:20"),
                    FerryTrip(id: "3", routeName: "石垣 → 波照間", departureTime: "10:00", arrivalTime: "11:30"),
                ]
            ),
            FerryCompanySchedule(
                id: "ishigaki-anei",
                company: aneiKanko,
                trips: [
                    FerryTrip(id: "1", routeName: "石垣 → 黒島", departureTime: "07:30", arrivalTime: "08:00"),
                    FerryTrip(id: "2", routeName: "石垣 → 与那国", departureTime: "07:00", arrivalTime: "08:30"),
                ]
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
        flightSchedules: yonaguniLineFlightSchedules,
        flightScheduleNote: flightScheduleNote
    )

    // MARK: - 竹富島

    private static let taketomi = IslandProfile(
        island: Island(id: "taketomi", nameJapanese: "竹富島", nameEnglish: "Taketomi", latitude: 24.3256, longitude: 124.0850),
        regionID: "yaeyama",
        port: IslandPort(name: "竹富港", latitude: 24.3250, longitude: 124.0890),
        backgroundAssetName: "IslandBgTaketomi",
        backgroundCredit: "Photo: Unsplash",
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["竹富"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "taketomi-yaeyama",
                company: yaeyamaFerry,
                trips: [
                    FerryTrip(id: "1", routeName: "竹富 → 石垣", departureTime: "08:30", arrivalTime: "08:40"),
                    FerryTrip(id: "2", routeName: "石垣 → 竹富", departureTime: "14:00", arrivalTime: "14:10"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "taketomi-clinic", category: .medical, name: "竹富診療所", phoneNumber: "0980-85-2133", address: "沖縄県竹富町竹富402", websiteURL: nil, note: "平日診療（詳細は要確認）"),
            UsefulInfo(id: "taketomi-convenience", category: .convenience, name: "竹富港・集落周辺", phoneNumber: nil, address: "竹富港から徒歩圏内", websiteURL: nil, note: "コンビニ・ATMは集落内に少数"),
            UsefulInfo(id: "taketomi-tourism", category: .tourism, name: "竹富町観光協会", phoneNumber: "0980-85-2441", address: "沖縄県竹富町竹富", websiteURL: "https://www.taketomijima.jp/", note: "水牛車・サイクル観光の案内"),
        ],
        liveCameras: [
            LiveCamera(title: "八重山リアルタイム（竹富島周辺）", urlString: "https://www.youtube.com/@YAEYAMALIVE"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil
    )

    // MARK: - 黒島

    private static let kuroshima = IslandProfile(
        island: Island(id: "kuroshima", nameJapanese: "黒島", nameEnglish: "Kuroshima", latitude: 24.2450, longitude: 123.8956),
        regionID: "yaeyama",
        port: IslandPort(name: "黒島港", latitude: 24.2457, longitude: 123.8947),
        backgroundAssetName: "IslandBgKuroshima",
        backgroundCredit: "Photo: Unsplash（沖縄の海と緑）",
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["黒島"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "kuroshima-anei",
                company: aneiKanko,
                trips: [
                    FerryTrip(id: "1", routeName: "石垣 → 黒島", departureTime: "07:30", arrivalTime: "08:00"),
                    FerryTrip(id: "2", routeName: "黒島 → 石垣", departureTime: "16:00", arrivalTime: "16:30"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "kuroshima-clinic", category: .medical, name: "黒島診療所", phoneNumber: "0980-95-2211", address: "沖縄県竹富町黒島", websiteURL: nil, note: nil),
            UsefulInfo(id: "kuroshima-convenience", category: .convenience, name: "黒島港周辺", phoneNumber: nil, address: "黒島港・集落", websiteURL: nil, note: "店舗は限られます。現金の用意を"),
            UsefulInfo(id: "kuroshima-tourism", category: .tourism, name: "黒島観光案内（竹富町）", phoneNumber: "0980-85-2441", address: "竹富町役場観光課", websiteURL: "https://www.taketomijima.jp/", note: "黒島は竹富町に属します"),
        ],
        liveCameras: [
            LiveCamera(title: "八重山リアルタイム（黒島周辺）", urlString: "https://www.youtube.com/@YAEYAMALIVE"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil
    )

    // MARK: - 波照間島

    private static let hateruma = IslandProfile(
        island: Island(id: "hateruma", nameJapanese: "波照間島", nameEnglish: "Hateruma", latitude: 24.0583, longitude: 123.8061),
        regionID: "yaeyama",
        port: IslandPort(name: "波照間港", latitude: 24.0580, longitude: 123.8050),
        backgroundAssetName: "IslandBgHateruma",
        backgroundCredit: "Photo: Unsplash（南国の海）",
        placeSearchRadiusMeters: 10_000,
        routeKeywords: ["波照間"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "hateruma-yaeyama",
                company: yaeyamaFerry,
                trips: [
                    FerryTrip(id: "1", routeName: "石垣 → 波照間", departureTime: "10:00", arrivalTime: "11:30"),
                    FerryTrip(id: "2", routeName: "波照間 → 石垣", departureTime: "15:00", arrivalTime: "16:30"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "hateruma-clinic", category: .medical, name: "波照間診療所", phoneNumber: "0980-85-8120", address: "沖縄県竹富町波照間", websiteURL: nil, note: nil),
            UsefulInfo(id: "hateruma-convenience", category: .convenience, name: "港・集落周辺の店舗", phoneNumber: nil, address: "波照間港付近", websiteURL: nil, note: "コンビニ・ATMは少なめです"),
            UsefulInfo(id: "hateruma-tourism", category: .tourism, name: "波照間島観光案内", phoneNumber: "0980-85-8767", address: "沖縄県竹富町波照間", websiteURL: "https://painusima.com/category/sima/haterumajima/", note: "最南端の碑・星空観測など"),
        ],
        liveCameras: [
            LiveCamera(title: "八重山リアルタイム（波照間方面）", urlString: "https://www.youtube.com/@YAEYAMALIVE"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil
    )

    // MARK: - 西表島

    private static let iriomote = IslandProfile(
        island: Island(id: "iriomote", nameJapanese: "西表島", nameEnglish: "Iriomote", latitude: 24.4167, longitude: 123.8167),
        regionID: "yaeyama",
        port: IslandPort(name: "大原港", latitude: 24.4183, longitude: 123.7940),
        backgroundAssetName: "IslandBgIriomote",
        backgroundCredit: "Photo: Unsplash（森と自然）",
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["大原", "上原", "西表", "由布"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "iriomote-yaeyama",
                company: yaeyamaFerry,
                trips: [
                    FerryTrip(id: "1", routeName: "石垣 → 西表（大原）", departureTime: "08:30", arrivalTime: "09:20"),
                    FerryTrip(id: "2", routeName: "西表（大原） → 石垣", departureTime: "17:00", arrivalTime: "17:50"),
                ]
            ),
            FerryCompanySchedule(
                id: "iriomote-jyosen",
                company: irimoteJyosen,
                trips: [
                    FerryTrip(id: "1", routeName: "西表（宇波利） → 由布島", departureTime: "09:00", arrivalTime: "09:10"),
                    FerryTrip(id: "2", routeName: "由布島 → 西表（宇波利）", departureTime: "16:00", arrivalTime: "16:10"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "iriomote-clinic-west", category: .medical, name: "西表西部診療所（上原）", phoneNumber: "0980-85-9111", address: "沖縄県竹富町上原", websiteURL: nil, note: "大原港方面の診療所"),
            UsefulInfo(id: "iriomote-clinic-east", category: .medical, name: "西表東部診療所（大原）", phoneNumber: "0980-85-9110", address: "沖縄県竹富町大原", websiteURL: nil, note: "上原港方面の診療所"),
            UsefulInfo(id: "iriomote-convenience", category: .convenience, name: "大原・上原の港周辺", phoneNumber: nil, address: "各港の集落", websiteURL: nil, note: "大原港・上原港付近に店舗・ATM"),
            UsefulInfo(id: "iriomote-tourism", category: .tourism, name: "西表島観光協会", phoneNumber: "0980-85-6185", address: "沖縄県竹富町大原", websiteURL: "https://www.iriomote.com/", note: "カヤック・トレッキング等の案内"),
        ],
        liveCameras: [
            LiveCamera(title: "西表島ライブカメラ（ヤシガニNET）", urlString: "https://www.youtube.com/@iriomote1956"),
            LiveCamera(title: "八重山リアルタイム（西表島周辺）", urlString: "https://www.youtube.com/@YAEYAMALIVE"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil
    )

    // MARK: - 与那国島

    private static let yonaguni = IslandProfile(
        island: Island(id: "yonaguni", nameJapanese: "与那国島", nameEnglish: "Yonaguni", latitude: 24.4667, longitude: 122.9833),
        regionID: "yaeyama",
        port: IslandPort(name: "与那国港", latitude: 24.4670, longitude: 122.9780),
        backgroundAssetName: "IslandBgYonaguni",
        backgroundCredit: "Photo: Unsplash（荒波の海）",
        placeSearchRadiusMeters: 10_000,
        routeKeywords: ["与那国"],
        ferryGTFSFeeds: [FerryGTFSFeedCatalog.fukuyama, FerryGTFSFeedCatalog.anei, FerryGTFSFeedCatalog.yaeyamaFerry],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "yonaguni-anei",
                company: aneiKanko,
                trips: [
                    FerryTrip(id: "1", routeName: "石垣 → 与那国", departureTime: "07:00", arrivalTime: "08:30"),
                    FerryTrip(id: "2", routeName: "与那国 → 石垣", departureTime: "16:30", arrivalTime: "18:00"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "yonaguni-clinic", category: .medical, name: "与那国診療所", phoneNumber: "0980-87-2133", address: "沖縄県与那国町与那国", websiteURL: nil, note: nil),
            UsefulInfo(id: "yonaguni-convenience", category: .convenience, name: "久部良港・集落周辺", phoneNumber: nil, address: "与那国港付近", websiteURL: nil, note: "店舗は限られます"),
            UsefulInfo(id: "yonaguni-tourism", category: .tourism, name: "与那国町観光協会", phoneNumber: "0980-87-2441", address: "沖縄県与那国町与那国", websiteURL: "https://welcome-yonaguni.jp/", note: "最西端の碑・ダイビング等"),
        ],
        liveCameras: [
            LiveCamera(title: "八重山リアルタイム（ライブ配信）", urlString: "https://www.youtube.com/@YAEYAMALIVE/live"),
            LiveCamera(title: "西埼灯台（海上保安庁・公式ページ）", urlString: "https://www6.kaiho.mlit.go.jp/11kanku/ishigaki/irisaki_lt/livecamera/index.html"),
        ],
        liveCameraFootnote: "※ 海上保安庁の灯台カメラはスマホで真っ白になることがあります。上のYouTubeリンクをお試しください。",
        flightSchedules: yonaguniLineFlightSchedules,
        flightScheduleNote: flightScheduleNote
    )
}
