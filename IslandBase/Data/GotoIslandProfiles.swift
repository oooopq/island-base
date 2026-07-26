//
//  GotoIslandProfiles.swift
//  Island Base
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
        websiteURL: "https://goto-ryokyakusen.com/guide/",
        phoneNumber: "0959-72-8151",
        statusPageURL: "https://goto-ryokyakusen.com/",
        homePageURL: "https://goto-ryokyakusen.com/"
    )

    private static let kiguchiKisen = FerryCompany(
        name: "木口汽船",
        websiteURL: "http://www.kiguchi-kisen.jp/",
        phoneNumber: "0959-73-0003",
        statusPageURL: "http://www.kiguchi-kisen.jp/",
        homePageURL: "http://www.kiguchi-kisen.jp/"
    )

    private static let kyushuShosen = FerryCompany(
        name: "九州商船株式会社",
        websiteURL: "https://kyusho.co.jp/schedule",
        phoneNumber: "095-822-0101",
        statusPageURL: "https://kyusho.co.jp/status",
        homePageURL: "https://kyusho.co.jp/"
    )

    private static let ana = FlightAirline(
        name: "全日本空輸（ANA）",
        websiteURL: "https://www.ana.co.jp/",
        phoneNumber: "0570-029-222",
        statusPageURL: "https://www.ana.co.jp/fs/dom/jp/"
    )


    private static let gotoTourismURL = "https://goto.nagasaki-tabinet.com/"

    private static func gotoYouTube(title: String) -> LiveCamera {
        LiveCamera(title: title, urlString: gotoTourismURL)
    }


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
        jmaMarineForecastArea: .nagasakiWest,
        backgroundAssetName: "IslandBgFukue",
        backgroundCredit: "Photo: Hiroaki Kaneko / Wikimedia Commons（堂崎天主堂）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 20_000,
        routeKeywords: ["福江", "五島", "福江島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "fukue-goto-ocean",
                company: gotoRyokyakusen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "fukue-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
            FerryCompanySchedule(
                id: "fukue-kyushu-nagasaki",
                company: kyushuShosen,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "fukue-hospital", category: .medical, name: "長崎県五島中央病院", phoneNumber: "0959-72-3181", address: "長崎県五島市吉久木町205番地", websiteURL: "https://www.gotocyuoh-hospital.jp/", note: "五島列島の中核病院"),
            UsefulInfo(id: "fukue-tourism", category: .tourism, name: "五島の島たび（公式）", phoneNumber: "0959-72-3177", address: "長崎県五島市東浜町2-3-1", websiteURL: gotoTourismURL, note: "観光・交通案内"),
            UsefulInfo(id: "fukue-convenience", category: .convenience, name: "福江港・市街地周辺", phoneNumber: nil, address: "福江港ターミナル・中央町付近", websiteURL: nil, note: "コンビニ・ATMあり"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            gotoYouTube(title: "五島の島たび（公式）"),
        ],
        flightSchedules: [
            FlightAirlineSchedule(id: "fukue-ana", airline: ana, trips: []),
        ],
        flightScheduleNote: nil,
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
        jmaMarineForecastArea: .nagasakiWest,
        backgroundAssetName: "IslandBgHisaka",
        backgroundCredit: "Photo: Marine-Blue / Wikimedia Commons（旧五輪教会）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["久賀", "久賀島", "田ノ浦"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "hisaka-kiguchi-hisaka",
                company: kiguchiKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "hisaka-kiguchi-seagull",
                company: kiguchiKisen,
                trips: [],
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
        jmaMarineForecastArea: .nagasakiWest,
        backgroundAssetName: "IslandBgNaru",
        backgroundCredit: "Photo: Indiana jo / Wikimedia Commons（江上天主堂）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["奈留", "奈留島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "naru-goto-ocean",
                company: gotoRyokyakusen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "naru-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [],
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
        jmaMarineForecastArea: .nagasakiWest,
        backgroundAssetName: "IslandBgWakamatsu",
        backgroundCredit: "Photo: Ebizur / Wikimedia Commons（若松大橋）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 8_000,
        routeKeywords: ["若松", "若松島", "土井浦"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "wakamatsu-goto-ocean",
                company: gotoRyokyakusen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "wakamatsu-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [],
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
        jmaMarineForecastArea: .nagasakiWest,
        backgroundAssetName: "IslandBgNakadori",
        backgroundCredit: "Photo: Sapphire123 / Wikimedia Commons（青嵐教会）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 15_000,
        routeKeywords: ["中通", "中通島", "郷ノ首", "奈良尾", "新上五島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "nakadori-goto-taiyo",
                company: gotoRyokyakusen,
                trips: [],
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
