//
//  IzuIslandProfiles.swift
//  Island Base
//
//  伊豆諸島の島データ
//  港座標: OpenStreetMap ferry_terminal / pier / dock
//

import Foundation

enum IzuIslandProfiles {
    static let all: [IslandProfile] = [
        oshima,
        toshima,
        niijima,
        shikinejima,
        kozushima,
        miyakejima,
        mikurajima,
        hachijojima,
    ]

    // MARK: - 共有データ

    private static let tokaiKisen = FerryCompany(
        name: "東海汽船株式会社",
        websiteURL: "https://www.tokaikisen.co.jp/boarding/timetable/",
        phoneNumber: "03-5472-9999",
        statusPageURL: "https://www.tokaikisen.co.jp/schedule/",
        homePageURL: "https://www.tokaikisen.co.jp/"
    )

    private static let ana = FlightAirline(
        name: "全日本空輸（ANA）",
        websiteURL: "https://www.ana.co.jp/",
        phoneNumber: "0570-029-222",
        statusPageURL: "https://www.ana.co.jp/fs/dom/jp/"
    )

    private static let shinChuoAir = FlightAirline(
        name: "新中央航空",
        websiteURL: "https://central-air.co.jp/schedule-fee.html",
        phoneNumber: "042-548-0100",
        statusPageURL: "https://central-air.co.jp/status.html"
    )


    private static let youtubeFallback = LiveCamera(
        title: "東海汽船（公式）",
        urlString: "https://www.tokaikisen.co.jp/"
    )

    // MARK: - 大島

    private static let oshima = IslandProfile(
        island: Island(
            id: "oshima",
            nameJapanese: "大島",
            nameEnglish: "Oshima",
            latitude: 34.737500,
            longitude: 139.398817
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "岡田港", latitude: 34.790559, longitude: 139.390640),
            IslandPort(name: "元町港", latitude: 34.751962, longitude: 139.352509),
        ],
        jmaMarineForecastArea: .kantoNorth,
        backgroundAssetName: "IslandBgOshima",
        backgroundCredit: "Photo: Donners / Wikimedia Commons（伊豆大島）／CC BY-SA 1.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["伊豆大島", "大島", "岡田", "元町", "三原山"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "oshima-tokai-jet",
                company: tokaiKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
            FerryCompanySchedule(
                id: "oshima-tokai-overnight",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "oshima-hospital", category: .medical, name: "大島医療センター", phoneNumber: "04992-2-2345", address: "東京都大島町元町三丁目２番地９", websiteURL: "https://www.town.oshima.tokyo.jp/soshiki/soumu/map-hospital.html", note: "伊豆大島の中核医療機関（救急対応）"),
            UsefulInfo(id: "oshima-convenience", category: .convenience, name: "元町・岡田港周辺", phoneNumber: nil, address: "元町港・岡田港ターミナル付近", websiteURL: nil, note: "セブン-イレブン、ローソン、ゆうちょATMなど"),
            UsefulInfo(id: "oshima-tourism", category: .tourism, name: "大島町観光協会", phoneNumber: "04992-2-1370", address: "東京都大島町元町", websiteURL: "https://www.izu-oshima.or.jp/", note: "三原山・椿の観光案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [
            FlightAirlineSchedule(id: "oshima-shinchuo", airline: shinChuoAir, trips: []),
        ],
        flightScheduleNote: nil,
    )

    // MARK: - 利島

    private static let toshima = IslandProfile(
        island: Island(
            id: "toshima",
            nameJapanese: "利島",
            nameEnglish: "Toshima",
            latitude: 34.522401,
            longitude: 139.279138
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "利島港", latitude: 34.532398, longitude: 139.281009),
        ],
        jmaMarineForecastArea: .kantoNorth,
        backgroundAssetName: "IslandBgToshima",
        backgroundCredit: "Photo: User: (WT-shared) Shoestring / Wikimedia Commons（利島・東京）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 4_000,
        routeKeywords: ["利島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "toshima-tokai",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "toshima-clinic", category: .medical, name: "利島診療所", phoneNumber: "04992-9-0011", address: "東京都利島村利島字利島", websiteURL: nil, note: nil),
            UsefulInfo(id: "toshima-convenience", category: .convenience, name: "利島港周辺", phoneNumber: nil, address: "利島港・集落", websiteURL: nil, note: "店舗・ATMは限られます"),
            UsefulInfo(id: "toshima-tourism", category: .tourism, name: "利島村観光", phoneNumber: "04992-9-0011", address: "東京都利島村", websiteURL: "https://www.toshimamura.org/tourism", note: "椿・ダイビングの案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 新島

    private static let niijima = IslandProfile(
        island: Island(
            id: "niijima",
            nameJapanese: "新島",
            nameEnglish: "Niijima",
            latitude: 34.376881,
            longitude: 139.266707
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "前浜港", latitude: 34.366944, longitude: 139.244167),
        ],
        jmaMarineForecastArea: .kantoNorth,
        backgroundAssetName: "IslandBgNiijima",
        backgroundCredit: "Photo: Fumiaki Hayashi / Unsplash（新島・白ママ層崖）",
        placeSearchRadiusMeters: 10_000,
        routeKeywords: ["新島", "前浜", "若郷"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "niijima-tokai-jet",
                company: tokaiKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
            FerryCompanySchedule(
                id: "niijima-tokai-overnight",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(
                id: "niijima-hospital",
                category: .medical,
                name: "新島村国民健康保険診療所（本村）",
                phoneNumber: "04992-5-0083",
                address: "東京都新島村本村4-10-3",
                websiteURL: "https://www.niijima.com/facility/health-center_clinic/shinryoujo/index.html",
                note: "若郷診療所（若郷1-5）もあり",
                navigationLatitude: 34.3708236,
                navigationLongitude: 139.2572467
            ),
            UsefulInfo(id: "niijima-convenience", category: .convenience, name: "前浜港・本村周辺", phoneNumber: nil, address: "前浜港付近", websiteURL: nil, note: "コンビニ・ATMは少数"),
            UsefulInfo(id: "niijima-tourism", category: .tourism, name: "新島村観光協会", phoneNumber: "04992-5-0018", address: "東京都新島村", websiteURL: "https://www.niijima.com/", note: "サーフィン・温泉の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [
            FlightAirlineSchedule(id: "niijima-shinchuo", airline: shinChuoAir, trips: []),
        ],
        flightScheduleNote: nil,
    )

    // MARK: - 式根島

    private static let shikinejima = IslandProfile(
        island: Island(
            id: "shikinejima",
            nameJapanese: "式根島",
            nameEnglish: "Shikinejima",
            latitude: 34.325458,
            longitude: 139.211336
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "野伏港", latitude: 34.333636, longitude: 139.215258),
        ],
        jmaMarineForecastArea: .kantoNorth,
        backgroundAssetName: "IslandBgShikinejima",
        backgroundCredit: "Photo: takeakisky homma / Wikimedia Commons（式根島・泊海水浴場）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["式根", "式根島", "野伏"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "shikine-tokai",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(
                id: "shikine-clinic",
                category: .medical,
                name: "新島村国民健康保険診療所（式根島）",
                phoneNumber: "04992-7-0019",
                address: "東京都新島村式根島311-1",
                websiteURL: "https://www.niijima.com/facility/health-center_clinic/shinryoujo/index.html",
                note: nil,
                navigationLatitude: 34.3263076,
                navigationLongitude: 139.2151854
            ),
            UsefulInfo(id: "shikine-convenience", category: .convenience, name: "野伏港周辺", phoneNumber: nil, address: "野伏港・集落", websiteURL: nil, note: "店舗は限られます"),
            UsefulInfo(id: "shikine-tourism", category: .tourism, name: "新島村観光協会（式根島）", phoneNumber: "04992-5-0018", address: "東京都新島村", websiteURL: "https://www.niijima.com/", note: "式根島は新島村に属します"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 神津島

    private static let kozushima = IslandProfile(
        island: Island(
            id: "kozushima",
            nameJapanese: "神津島",
            nameEnglish: "Kozushima",
            latitude: 34.214406,
            longitude: 139.147786
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "神津港", latitude: 34.210796, longitude: 139.129848),
        ],
        jmaMarineForecastArea: .kantoNorth,
        backgroundAssetName: "IslandBgKozushima",
        backgroundCredit: "Photo: Ice Tea / Unsplash（神津島）",
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["神津", "神津島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "kozu-tokai-jet",
                company: tokaiKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
            FerryCompanySchedule(
                id: "kozu-tokai-overnight",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "kozu-clinic", category: .medical, name: "神津島診療所", phoneNumber: "04992-8-0011", address: "東京都神津島村神津島", websiteURL: nil, note: nil),
            UsefulInfo(id: "kozu-convenience", category: .convenience, name: "神津港周辺", phoneNumber: nil, address: "神津港・集落", websiteURL: nil, note: "コンビニ・ATMは少数"),
            UsefulInfo(id: "kozu-tourism", category: .tourism, name: "神津島村観光協会", phoneNumber: "04992-8-0051", address: "東京都神津島村", websiteURL: "https://kozushima.com/", note: "ダイビング・星空の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [
            FlightAirlineSchedule(id: "kozushima-shinchuo", airline: shinChuoAir, trips: []),
        ],
        flightScheduleNote: nil,
    )

    // MARK: - 三宅島

    private static let miyakejima = IslandProfile(
        island: Island(
            id: "miyakejima",
            nameJapanese: "三宅島",
            nameEnglish: "Miyakejima",
            latitude: 34.084926,
            longitude: 139.521135
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "三池港", latitude: 34.079750, longitude: 139.563624),
            IslandPort(name: "阿古港", latitude: 34.068218, longitude: 139.478162),
        ],
        jmaMarineForecastArea: .kantoNorth,
        backgroundAssetName: "IslandBgMiyakejima",
        backgroundCredit: "Photo: Marek Okon / Unsplash（三宅島）",
        placeSearchRadiusMeters: 12_000,
        routeKeywords: ["三宅", "三宅島", "三池", "阿古", "錆ヶ浜"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "miyake-tokai",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "miyake-hospital", category: .medical, name: "三宅島病院", phoneNumber: "04994-4-2111", address: "東京都三宅村伊ヶ谷", websiteURL: nil, note: "三宅島の中核病院"),
            UsefulInfo(id: "miyake-convenience", category: .convenience, name: "三池港・阿古周辺", phoneNumber: nil, address: "三池港・阿古港付近", websiteURL: nil, note: "セブン-イレブン、ローソンなど"),
            UsefulInfo(id: "miyake-tourism", category: .tourism, name: "三宅村観光協会", phoneNumber: "04994-4-2211", address: "東京都三宅村", websiteURL: "https://www.miyakejima.gr.jp/", note: "ダイビング・トレッキングの案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [
            FlightAirlineSchedule(id: "miyake-shinchuo", airline: shinChuoAir, trips: []),
        ],
        flightScheduleNote: nil,
    )

    // MARK: - 御蔵島

    private static let mikurajima = IslandProfile(
        island: Island(
            id: "mikurajima",
            nameJapanese: "御蔵島",
            nameEnglish: "Mikurajima",
            latitude: 33.874827,
            longitude: 139.603204
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "御蔵島港", latitude: 33.897239, longitude: 139.589880),
        ],
        jmaMarineForecastArea: .kantoSouth,
        backgroundAssetName: "IslandBgMikurajima",
        backgroundCredit: "Photo: 名古屋太郎 / Wikimedia Commons（御蔵島）／Public domain／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 5_000,
        routeKeywords: ["御蔵", "御蔵島", "玄ヶ浦"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "mikura-tokai",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "mikura-clinic", category: .medical, name: "御蔵島診療所", phoneNumber: "04994-39-2111", address: "東京都御蔵島村", websiteURL: nil, note: nil),
            UsefulInfo(id: "mikura-convenience", category: .convenience, name: "御蔵島港周辺", phoneNumber: nil, address: "御蔵島港・里浜", websiteURL: nil, note: "店舗は限られます"),
            UsefulInfo(id: "mikura-tourism", category: .tourism, name: "御蔵島村観光", phoneNumber: "04996-2-0011", address: "東京都御蔵島村", websiteURL: "https://mikura-isle.com/", note: "イルカ・ダイビングの案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 八丈島

    private static let hachijojima = IslandProfile(
        island: Island(
            id: "hachijojima",
            nameJapanese: "八丈島",
            nameEnglish: "Hachijojima",
            latitude: 33.106385,
            longitude: 139.797940
        ),
        regionID: "izu",
        ports: [
            IslandPort(name: "八重根港", latitude: 33.097875, longitude: 139.769695),
            IslandPort(name: "底土港", latitude: 33.123615, longitude: 139.821233),
        ],
        jmaMarineForecastArea: .kantoSouth,
        backgroundAssetName: "IslandBgHachijojima",
        backgroundCredit: "Photo: Tomoyuki Shidara（八丈島）",
        placeSearchRadiusMeters: 15_000,
        routeKeywords: ["八丈", "八丈島", "八重根", "底土"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "hachijo-tokai",
                company: tokaiKisen,
                trips: [],
                serviceKind: .overnightFerry
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "hachijo-hospital", category: .medical, name: "八丈島立総合病院", phoneNumber: "04996-2-3111", address: "東京都八丈町大賀郷", websiteURL: nil, note: "八丈島の中核病院（救急対応）"),
            UsefulInfo(id: "hachijo-convenience", category: .convenience, name: "八重根・底土港周辺", phoneNumber: nil, address: "各港ターミナル付近", websiteURL: nil, note: "セブン-イレブン、ローソン、ゆうちょATMなど"),
            UsefulInfo(id: "hachijo-tourism", category: .tourism, name: "八丈町観光協会", phoneNumber: "04996-2-1377", address: "東京都八丈町", websiteURL: "https://www.hachijo.gr.jp/", note: "温泉・トレッキングの案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [
            FlightAirlineSchedule(id: "hachijo-ana", airline: ana, trips: []),
        ],
        flightScheduleNote: nil,
    )
}
