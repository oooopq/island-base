//
//  IzuIslandProfiles.swift
//  Island Now
//
//  伊豆諸島の島データ
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
        websiteURL: "https://www.tokaikisen.co.jp/",
        phoneNumber: "03-5472-9999"
    )

    private static let ana = FlightAirline(
        name: "全日本空輸（ANA）",
        websiteURL: "https://www.ana.co.jp/",
        phoneNumber: "0570-029-222"
    )

    private static let flightScheduleNote = "代表ダイヤです。季節・天候により変更・欠航があります。"

    private static let backgroundAssetName = "IslandBgIzu"
    private static let backgroundCredit = "Photo: Unsplash（伊豆諸島・海）"

    private static let youtubeFallback = LiveCamera(
        title: "東海汽船（公式）",
        urlString: "https://www.youtube.com/@tokaikisen"
    )

    private static let oshimaFlights: [FlightTrip] = [
        FlightTrip(id: "ana781", flightNumber: "ANA781", routeName: "東京 → 大島", departureTime: "08:00", arrivalTime: "08:35"),
        FlightTrip(id: "ana783", flightNumber: "ANA783", routeName: "東京 → 大島", departureTime: "14:30", arrivalTime: "15:05"),
        FlightTrip(id: "ana782", flightNumber: "ANA782", routeName: "大島 → 東京", departureTime: "09:05", arrivalTime: "09:40"),
        FlightTrip(id: "ana784", flightNumber: "ANA784", routeName: "大島 → 東京", departureTime: "15:35", arrivalTime: "16:10"),
    ]

    private static let miyakeFlights: [FlightTrip] = [
        FlightTrip(id: "ana791", flightNumber: "ANA791", routeName: "東京 → 三宅", departureTime: "09:00", arrivalTime: "09:45"),
        FlightTrip(id: "ana792", flightNumber: "ANA792", routeName: "三宅 → 東京", departureTime: "10:15", arrivalTime: "11:00"),
    ]

    private static let hachijoFlights: [FlightTrip] = [
        FlightTrip(id: "ana801", flightNumber: "ANA801", routeName: "東京 → 八丈", departureTime: "08:30", arrivalTime: "09:30"),
        FlightTrip(id: "ana803", flightNumber: "ANA803", routeName: "東京 → 八丈", departureTime: "15:00", arrivalTime: "16:00"),
        FlightTrip(id: "ana802", flightNumber: "ANA802", routeName: "八丈 → 東京", departureTime: "10:00", arrivalTime: "11:00"),
        FlightTrip(id: "ana804", flightNumber: "ANA804", routeName: "八丈 → 東京", departureTime: "16:30", arrivalTime: "17:30"),
    ]

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
            IslandPort(name: "岡田港", latitude: 34.789980, longitude: 139.389670),
            IslandPort(name: "元町港", latitude: 34.751139, longitude: 139.351472),
        ],
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["伊豆大島", "大島", "岡田", "元町", "三原山"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "oshima-tokai-jet",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 大島", departureTime: "08:35", arrivalTime: "10:20"),
                    FerryTrip(id: "2", routeName: "大島 → 東京", departureTime: "15:30", arrivalTime: "17:15"),
                ]
            ),
            FerryCompanySchedule(
                id: "oshima-tokai-overnight",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 大島", departureTime: "22:00", arrivalTime: "06:00"),
                    FerryTrip(id: "2", routeName: "大島 → 東京", departureTime: "07:00", arrivalTime: "15:00"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "oshima-hospital", category: .medical, name: "大島病院", phoneNumber: "04992-2-2111", address: "東京都大島町元町字浜之町", websiteURL: "https://www.oshimahp.or.jp/", note: "伊豆大島の中核病院（救急対応）"),
            UsefulInfo(id: "oshima-convenience", category: .convenience, name: "元町・岡田港周辺", phoneNumber: nil, address: "元町港・岡田港ターミナル付近", websiteURL: nil, note: "セブン-イレブン、ローソン、ゆうちょATMなど"),
            UsefulInfo(id: "oshima-tourism", category: .tourism, name: "大島町観光協会", phoneNumber: "04992-2-1370", address: "東京都大島町元町", websiteURL: "https://www.oshima-town.org/kanko/", note: "三原山・椿の観光案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [
            FlightAirlineSchedule(id: "oshima-ana", airline: ana, trips: oshimaFlights),
        ],
        flightScheduleNote: flightScheduleNote,
        wbgtStationNo: 44_172
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
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 4_000,
        routeKeywords: ["利島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "toshima-tokai",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 利島", departureTime: "22:00", arrivalTime: "07:40"),
                    FerryTrip(id: "2", routeName: "利島 → 東京", departureTime: "08:00", arrivalTime: "17:00"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "toshima-clinic", category: .medical, name: "利島診療所", phoneNumber: "04992-9-0011", address: "東京都利島村利島字利島", websiteURL: nil, note: nil),
            UsefulInfo(id: "toshima-convenience", category: .convenience, name: "利島港周辺", phoneNumber: nil, address: "利島港・集落", websiteURL: nil, note: "店舗・ATMは限られます"),
            UsefulInfo(id: "toshima-tourism", category: .tourism, name: "利島村観光", phoneNumber: "04992-9-0011", address: "東京都利島村", websiteURL: "https://www.toshima.gr.jp/", note: "椿・ダイビングの案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
        wbgtStationNo: 44_172
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
            IslandPort(name: "前浜港", latitude: 34.371954, longitude: 139.240214),
        ],
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 10_000,
        routeKeywords: ["新島", "前浜", "若郷"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "niijima-tokai-jet",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 新島", departureTime: "08:35", arrivalTime: "11:25"),
                    FerryTrip(id: "2", routeName: "新島 → 東京", departureTime: "14:00", arrivalTime: "16:50"),
                ]
            ),
            FerryCompanySchedule(
                id: "niijima-tokai-overnight",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 新島", departureTime: "22:00", arrivalTime: "08:35"),
                    FerryTrip(id: "2", routeName: "新島 → 東京", departureTime: "09:00", arrivalTime: "18:30"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "niijima-hospital", category: .medical, name: "新島病院", phoneNumber: "04992-5-2111", address: "東京都新島村本村", websiteURL: nil, note: "新島の中核病院"),
            UsefulInfo(id: "niijima-convenience", category: .convenience, name: "前浜港・本村周辺", phoneNumber: nil, address: "前浜港付近", websiteURL: nil, note: "コンビニ・ATMは少数"),
            UsefulInfo(id: "niijima-tourism", category: .tourism, name: "新島村観光協会", phoneNumber: "04992-5-0018", address: "東京都新島村", websiteURL: "https://www.niijima.com/", note: "サーフィン・温泉の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
        wbgtStationNo: 44_172
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
            IslandPort(name: "野伏港", latitude: 34.334440, longitude: 139.215280),
        ],
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["式根", "式根島", "野伏"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "shikine-tokai",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 式根島", departureTime: "22:00", arrivalTime: "09:05"),
                    FerryTrip(id: "2", routeName: "式根島 → 東京", departureTime: "10:00", arrivalTime: "19:00"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "shikine-clinic", category: .medical, name: "式根島診療所", phoneNumber: "04992-7-0011", address: "東京都新島村式根島", websiteURL: nil, note: nil),
            UsefulInfo(id: "shikine-convenience", category: .convenience, name: "野伏港周辺", phoneNumber: nil, address: "野伏港・集落", websiteURL: nil, note: "店舗は限られます"),
            UsefulInfo(id: "shikine-tourism", category: .tourism, name: "新島村観光協会（式根島）", phoneNumber: "04992-5-0018", address: "東京都新島村", websiteURL: "https://www.niijima.com/", note: "式根島は新島村に属します"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
        wbgtStationNo: 44_172
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
            IslandPort(name: "神津港", latitude: 34.207978, longitude: 139.131511),
        ],
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["神津", "神津島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "kozu-tokai-jet",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 神津島", departureTime: "08:35", arrivalTime: "12:15"),
                    FerryTrip(id: "2", routeName: "神津島 → 東京", departureTime: "13:00", arrivalTime: "16:40"),
                ]
            ),
            FerryCompanySchedule(
                id: "kozu-tokai-overnight",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 神津島", departureTime: "22:00", arrivalTime: "10:00"),
                    FerryTrip(id: "2", routeName: "神津島 → 東京", departureTime: "11:00", arrivalTime: "21:00"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "kozu-clinic", category: .medical, name: "神津島診療所", phoneNumber: "04992-8-0011", address: "東京都神津島村神津島", websiteURL: nil, note: nil),
            UsefulInfo(id: "kozu-convenience", category: .convenience, name: "神津港周辺", phoneNumber: nil, address: "神津港・集落", websiteURL: nil, note: "コンビニ・ATMは少数"),
            UsefulInfo(id: "kozu-tourism", category: .tourism, name: "神津島村観光協会", phoneNumber: "04992-8-0051", address: "東京都神津島村", websiteURL: "https://www.kouzushima.jp/", note: "ダイビング・星空の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
        wbgtStationNo: 44_172
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
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 12_000,
        routeKeywords: ["三宅", "三宅島", "三池", "阿古", "錆ヶ浜"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "miyake-tokai",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 三宅島", departureTime: "22:30", arrivalTime: "05:00"),
                    FerryTrip(id: "2", routeName: "三宅島 → 東京", departureTime: "13:35", arrivalTime: "19:40"),
                ]
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
            FlightAirlineSchedule(id: "miyake-ana", airline: ana, trips: miyakeFlights),
        ],
        flightScheduleNote: flightScheduleNote,
        wbgtStationNo: 44_226
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
            IslandPort(name: "御蔵島港", latitude: 33.897179, longitude: 139.589865),
        ],
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 5_000,
        routeKeywords: ["御蔵", "御蔵島", "玄ヶ浦"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "mikura-tokai",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 御蔵島", departureTime: "22:30", arrivalTime: "06:00"),
                    FerryTrip(id: "2", routeName: "御蔵島 → 東京", departureTime: "12:35", arrivalTime: "19:40"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "mikura-clinic", category: .medical, name: "御蔵島診療所", phoneNumber: "04994-39-2111", address: "東京都御蔵島村", websiteURL: nil, note: nil),
            UsefulInfo(id: "mikura-convenience", category: .convenience, name: "御蔵島港周辺", phoneNumber: nil, address: "御蔵島港・里浜", websiteURL: nil, note: "店舗は限られます"),
            UsefulInfo(id: "mikura-tourism", category: .tourism, name: "御蔵島村観光", phoneNumber: "04996-2-0011", address: "東京都御蔵島村", websiteURL: "https://www.mikurasima.jp/", note: "イルカ・ダイビングの案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [youtubeFallback],
        flightSchedules: [],
        flightScheduleNote: nil,
        wbgtStationNo: 44_226
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
            IslandPort(name: "底土港", latitude: 33.121462, longitude: 139.819011),
        ],
        backgroundAssetName: backgroundAssetName,
        backgroundCredit: backgroundCredit,
        placeSearchRadiusMeters: 15_000,
        routeKeywords: ["八丈", "八丈島", "八重根", "底土"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "hachijo-tokai",
                company: tokaiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "東京 → 八丈島", departureTime: "22:30", arrivalTime: "08:55"),
                    FerryTrip(id: "2", routeName: "八丈島 → 東京", departureTime: "09:40", arrivalTime: "19:40"),
                ]
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
            FlightAirlineSchedule(id: "hachijo-ana", airline: ana, trips: hachijoFlights),
        ],
        flightScheduleNote: flightScheduleNote,
        wbgtStationNo: 44_263
    )
}
