//
//  GotoIslandProfiles.swift
//  Island Now
//
//  五島列島の島データ
//  島中心座標: OpenStreetMap 島ポリゴン重心。港座標: OSM ferry_terminal/pier、郷ノ首港は国土地理院。
//

import Foundation

enum GotoIslandProfiles {
    static let all: [IslandProfile] = [
        fukue,
        hisaka,
        naru,
        wakamatsu,
        nakadori,
    ]

    // MARK: - 共有データ

    private static let gotoRyokyakusen = FerryCompany(
        name: "五島旅客船株式会社",
        websiteURL: "https://goto-ryokyakusen.com/",
        phoneNumber: "0959-72-8151",
        statusPageURL: "https://goto-ryokyakusen.com/"
    )

    private static let kiguchiKisen = FerryCompany(
        name: "木口汽船",
        websiteURL: "http://www.kiguchi-kisen.jp/",
        phoneNumber: "0959-73-0003",
        statusPageURL: "http://www.kiguchi-kisen.jp/"
    )

    private static let kyushuShosen = FerryCompany(
        name: "九州商船株式会社",
        websiteURL: "https://kyusho.co.jp/schedule",
        phoneNumber: "095-822-0101",
        statusPageURL: "https://kyusho.co.jp/status"
    )

    private static let ana = FlightAirline(
        name: "全日本空輸（ANA）",
        websiteURL: "https://www.ana.co.jp/",
        phoneNumber: "0570-029-222",
        statusPageURL: "https://www.ana.co.jp/fs/dom/jp/"
    )

    private static let ferryScheduleNote = "代表ダイヤです。季節・天候・ドック等により変更・欠航があります。"
    private static let flightScheduleNote = "代表ダイヤです。季節により変更があります。"

    private static let gotoTourismURL = "https://goto.nagasaki-tabinet.com/"

    private static func gotoYouTube(title: String) -> LiveCamera {
        LiveCamera(title: title, urlString: gotoTourismURL)
    }

    // 五島空港（福江）— ANA 代表ダイヤ
    private static let fukueAnaFlights: [FlightTrip] = [
        FlightTrip(id: "ana384", flightNumber: "ANA384", routeName: "福岡 → 五島", departureTime: "10:05", arrivalTime: "10:45"),
        FlightTrip(id: "ana386", flightNumber: "ANA386", routeName: "福岡 → 五島", departureTime: "16:30", arrivalTime: "17:10"),
        FlightTrip(id: "ana385", flightNumber: "ANA385", routeName: "五島 → 福岡", departureTime: "11:15", arrivalTime: "11:55"),
        FlightTrip(id: "ana387", flightNumber: "ANA387", routeName: "五島 → 福岡", departureTime: "17:40", arrivalTime: "18:20"),
        FlightTrip(id: "ana490", flightNumber: "ANA490", routeName: "長崎 → 五島", departureTime: "09:15", arrivalTime: "09:45"),
        FlightTrip(id: "ana492", flightNumber: "ANA492", routeName: "長崎 → 五島", departureTime: "15:20", arrivalTime: "15:50"),
        FlightTrip(id: "ana491", flightNumber: "ANA491", routeName: "五島 → 長崎", departureTime: "10:05", arrivalTime: "10:35"),
        FlightTrip(id: "ana493", flightNumber: "ANA493", routeName: "五島 → 長崎", departureTime: "16:10", arrivalTime: "16:40"),
    ]

    // MARK: - 福江島

    private static let fukue = IslandProfile(
        island: Island(
            id: "fukue",
            nameJapanese: "福江島",
            nameEnglish: "Fukue",
            latitude: 32.686123,
            longitude: 128.747749
        ),
        regionID: "goto",
        ports: [
            IslandPort(name: "福江港", latitude: 32.696764, longitude: 128.852276),
            IslandPort(name: "奥浦港", latitude: 32.744615, longitude: 128.825669),
        ],
        backgroundAssetName: "IslandBgFukue",
        backgroundCredit: "Photo: Hiroaki Kaneko / Wikimedia Commons（堂崎天主堂）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 20_000,
        routeKeywords: ["福江", "五島", "福江島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "fukue-goto-ocean",
                company: gotoRyokyakusen,
                trips: [
                    FerryTrip(id: "1", routeName: "福江 → 奈留", departureTime: "08:05", arrivalTime: "08:50"),
                    FerryTrip(id: "2", routeName: "奈留 → 福江", departureTime: "09:00", arrivalTime: "09:45"),
                    FerryTrip(id: "3", routeName: "福江 → 若松", departureTime: "13:00", arrivalTime: "14:40"),
                    FerryTrip(id: "4", routeName: "若松 → 福江", departureTime: "14:55", arrivalTime: "16:40"),
                ]
            ),
            FerryCompanySchedule(
                id: "fukue-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [
                    FerryTrip(id: "1", routeName: "福江 → 奈留", departureTime: "09:45", arrivalTime: "10:15"),
                    FerryTrip(id: "2", routeName: "福江 → 若松", departureTime: "15:55", arrivalTime: "17:35"),
                    FerryTrip(id: "3", routeName: "若松 → 福江", departureTime: "07:30", arrivalTime: "09:15"),
                ],
                serviceKind: .highSpeedBoat
            ),
            FerryCompanySchedule(
                id: "fukue-kyushu-nagasaki",
                company: kyushuShosen,
                trips: [
                    FerryTrip(id: "1", routeName: "長崎 → 福江", departureTime: "08:05", arrivalTime: "11:15"),
                    FerryTrip(id: "2", routeName: "福江 → 長崎", departureTime: "08:00", arrivalTime: "11:45"),
                    FerryTrip(id: "3", routeName: "長崎 → 福江", departureTime: "16:50", arrivalTime: "20:00"),
                ]
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "fukue-hospital", category: .medical, name: "五島市立総合医療センター", phoneNumber: "0959-72-3121", address: "長崎県五島市東浜町1-16-1", websiteURL: "https://www.goto-hospital.jp/", note: "五島列島の中核病院"),
            UsefulInfo(id: "fukue-tourism", category: .tourism, name: "五島の島たび（公式）", phoneNumber: "0959-72-3177", address: "長崎県五島市東浜町2-3-1", websiteURL: gotoTourismURL, note: "観光・交通案内"),
            UsefulInfo(id: "fukue-convenience", category: .convenience, name: "福江港・市街地周辺", phoneNumber: nil, address: "福江港ターミナル・中央町付近", websiteURL: nil, note: "コンビニ・ATMあり"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            gotoYouTube(title: "五島の島たび（公式）"),
        ],
        flightSchedules: [
            FlightAirlineSchedule(id: "fukue-ana", airline: ana, trips: fukueAnaFlights),
        ],
        flightScheduleNote: flightScheduleNote,
    )

    // MARK: - 久賀島

    private static let hisaka = IslandProfile(
        island: Island(
            id: "hisaka",
            nameJapanese: "久賀島",
            nameEnglish: "Hisaka",
            latitude: 32.804108,
            longitude: 128.871510
        ),
        regionID: "goto",
        ports: [
            IslandPort(name: "田ノ浦港", latitude: 32.781865, longitude: 128.841986),
        ],
        backgroundAssetName: "IslandBgHisaka",
        backgroundCredit: "Photo: Marine-Blue / Wikimedia Commons（旧五輪教会）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["久賀", "久賀島", "田ノ浦"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "hisaka-kiguchi-hisaka",
                company: kiguchiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "福江 → 田ノ浦", departureTime: "07:30", arrivalTime: "07:49"),
                    FerryTrip(id: "2", routeName: "田ノ浦 → 福江", departureTime: "08:00", arrivalTime: "08:34"),
                    FerryTrip(id: "3", routeName: "福江 → 田ノ浦", departureTime: "13:35", arrivalTime: "14:09"),
                    FerryTrip(id: "4", routeName: "田ノ浦 → 福江", departureTime: "14:35", arrivalTime: "15:09"),
                ]
            ),
            FerryCompanySchedule(
                id: "hisaka-kiguchi-seagull",
                company: kiguchiKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "福江 → 田ノ浦", departureTime: "09:10", arrivalTime: "09:30"),
                    FerryTrip(id: "2", routeName: "田ノ浦 → 福江", departureTime: "09:35", arrivalTime: "09:55"),
                    FerryTrip(id: "3", routeName: "福江 → 田ノ浦", departureTime: "16:45", arrivalTime: "17:05"),
                    FerryTrip(id: "4", routeName: "田ノ浦 → 福江", departureTime: "17:10", arrivalTime: "17:30"),
                ],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "hisaka-clinic", category: .medical, name: "五島市国民健康保険 久賀診療所", phoneNumber: "0959-85-2131", address: "長崎県五島市久賀町久賀", websiteURL: nil, note: "島内診療所"),
            UsefulInfo(id: "hisaka-tourism", category: .tourism, name: "五島の島たび（久賀島）", phoneNumber: "0959-72-3177", address: nil, websiteURL: gotoTourismURL, note: "教会・集落景観の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            gotoYouTube(title: "五島の島たび（久賀島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 奈留島

    private static let naru = IslandProfile(
        island: Island(
            id: "naru",
            nameJapanese: "奈留島",
            nameEnglish: "Naru",
            latitude: 32.842128,
            longitude: 128.918679
        ),
        regionID: "goto",
        ports: [
            IslandPort(name: "奈留港", latitude: 32.822013, longitude: 128.938960),
        ],
        backgroundAssetName: "IslandBgNaru",
        backgroundCredit: "Photo: Indiana jo / Wikimedia Commons（江上天主堂）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["奈留", "奈留島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "naru-goto-ocean",
                company: gotoRyokyakusen,
                trips: [
                    FerryTrip(id: "1", routeName: "福江 → 奈留", departureTime: "08:05", arrivalTime: "08:50"),
                    FerryTrip(id: "2", routeName: "奈留 → 福江", departureTime: "09:00", arrivalTime: "09:45"),
                    FerryTrip(id: "3", routeName: "奈留 → 若松", departureTime: "10:30", arrivalTime: "11:20"),
                    FerryTrip(id: "4", routeName: "若松 → 奈留", departureTime: "11:30", arrivalTime: "12:15"),
                ]
            ),
            FerryCompanySchedule(
                id: "naru-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [
                    FerryTrip(id: "1", routeName: "福江 → 奈留", departureTime: "09:45", arrivalTime: "10:15"),
                    FerryTrip(id: "2", routeName: "奈留 → 福江", departureTime: "10:15", arrivalTime: "10:50"),
                    FerryTrip(id: "3", routeName: "福江 → 奈留", departureTime: "15:55", arrivalTime: "16:25"),
                ],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "naru-hospital", category: .medical, name: "五島市立総合医療センター（奈留診療所）", phoneNumber: "0959-64-2121", address: "長崎県五島市奈留町", websiteURL: nil, note: "診療時間は要確認"),
            UsefulInfo(id: "naru-tourism", category: .tourism, name: "五島の島たび（奈留島）", phoneNumber: "0959-72-3177", address: nil, websiteURL: gotoTourismURL, note: "観光・教会めぐり"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            gotoYouTube(title: "五島の島たび（奈留島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 若松島

    private static let wakamatsu = IslandProfile(
        island: Island(
            id: "wakamatsu",
            nameJapanese: "若松島",
            nameEnglish: "Wakamatsu",
            latitude: 32.888677,
            longitude: 128.997115
        ),
        regionID: "goto",
        ports: [
            IslandPort(name: "若松港", latitude: 32.898159, longitude: 128.999510),
            IslandPort(name: "土井浦港", latitude: 32.864775, longitude: 129.018491),
        ],
        backgroundAssetName: "IslandBgWakamatsu",
        backgroundCredit: "Photo: Ebizur / Wikimedia Commons（若松大橋）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["若松", "若松島", "土井浦"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "wakamatsu-goto-ocean",
                company: gotoRyokyakusen,
                trips: [
                    FerryTrip(id: "1", routeName: "若松 → 福江", departureTime: "06:35", arrivalTime: "07:20"),
                    FerryTrip(id: "2", routeName: "福江 → 若松", departureTime: "13:00", arrivalTime: "14:40"),
                    FerryTrip(id: "3", routeName: "若松 → 福江", departureTime: "14:55", arrivalTime: "16:40"),
                ]
            ),
            FerryCompanySchedule(
                id: "wakamatsu-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [
                    FerryTrip(id: "1", routeName: "若松 → 福江", departureTime: "07:30", arrivalTime: "09:15"),
                    FerryTrip(id: "2", routeName: "福江 → 若松", departureTime: "15:55", arrivalTime: "17:35"),
                    FerryTrip(id: "3", routeName: "若松 → 福江", departureTime: "10:50", arrivalTime: "11:20"),
                ],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "wakamatsu-tourism", category: .tourism, name: "五島の島たび（若松島）", phoneNumber: "0959-72-3177", address: nil, websiteURL: gotoTourismURL, note: "若松大橋・展望台の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            gotoYouTube(title: "五島の島たび（若松島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 中通島

    private static let nakadori = IslandProfile(
        island: Island(
            id: "nakadori",
            nameJapanese: "中通島",
            nameEnglish: "Nakadori",
            latitude: 32.990298,
            longitude: 129.087662
        ),
        regionID: "goto",
        ports: [
            IslandPort(name: "郷ノ首港", latitude: 32.925658, longitude: 129.037458),
            IslandPort(name: "奈良尾港", latitude: 32.846167, longitude: 129.061428),
        ],
        backgroundAssetName: "IslandBgNakadori",
        backgroundCredit: "Photo: Sapphire123 / Wikimedia Commons（青嵐教会）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 15_000,
        routeKeywords: ["中通", "中通島", "郷ノ首", "奈良尾", "新上五島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "nakadori-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [
                    FerryTrip(id: "1", routeName: "福江 → 郷ノ首", departureTime: "15:55", arrivalTime: "17:20"),
                    FerryTrip(id: "2", routeName: "郷ノ首 → 福江", departureTime: "07:45", arrivalTime: "09:15"),
                    FerryTrip(id: "3", routeName: "福江 → 郷ノ首", departureTime: "11:50", arrivalTime: "12:30"),
                    FerryTrip(id: "4", routeName: "郷ノ首 → 若松", departureTime: "17:20", arrivalTime: "17:35"),
                ],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "nakadori-tourism", category: .tourism, name: "新上五島町観光協会", phoneNumber: "0959-42-6111", address: "長崎県南松浦郡新上五島町有川町", websiteURL: "https://shinkamigoto.nagasaki-tabinet.com/", note: "上五島・中通島の観光案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            gotoYouTube(title: "五島の島たび（上五島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )
}
