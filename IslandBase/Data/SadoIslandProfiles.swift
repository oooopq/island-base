//
//  SadoIslandProfiles.swift
//  Island Base
//
//  佐渡島の島データ
//  港座標: OpenStreetMap ferry_terminal（佐渡汽船ターミナル）
//

import Foundation

enum SadoIslandProfiles {
    static let all: [IslandProfile] = [
        sado,
    ]

    // MARK: - 共有データ

    private static let sadoKisen = FerryCompany(
        name: "佐渡汽船株式会社",
        websiteURL: "https://www.sadokisen.co.jp/reservation/timetables/?route=1",
        phoneNumber: "025-245-6400",
        statusPageURL: "https://www.sadokisen.co.jp/reservation/service-status/",
        homePageURL: "https://www.sadokisen.co.jp/"
    )

    private static let ana = FlightAirline(
        name: "全日本空輸（ANA）",
        websiteURL: "https://www.ana.co.jp/",
        phoneNumber: "0570-029-222",
        statusPageURL: "https://www.ana.co.jp/fs/dom/jp/"
    )

    // MARK: - 佐渡島

    private static let sado = IslandProfile(
        island: Island(
            id: "sado",
            nameJapanese: "佐渡島",
            nameEnglish: "Sado",
            latitude: 38.044270,
            longitude: 138.389903
        ),
        regionID: "sado",
        ports: [
            IslandPort(name: "両津港", latitude: 38.081653, longitude: 138.438069),
            IslandPort(name: "小木港", latitude: 37.816271, longitude: 138.282232),
        ],
        jmaMarineForecastArea: .sadoOffshore,
        backgroundAssetName: "IslandBgSado",
        backgroundCredit: "Photo: 伊藤善行 / Wikimedia Commons（佐渡・矢島経島のたらい舟）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["佐渡", "両津", "小木"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "sado-kisen-niigata",
                company: sadoKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "sado-kisen-naoetsu",
                company: sadoKisen,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(
                id: "sado-hospital",
                category: .medical,
                name: "佐渡総合病院",
                phoneNumber: "0259-27-3111",
                address: "新潟県佐渡市千種乙233",
                websiteURL: "https://www.sadosogo-hp.jp/",
                note: "佐渡島の中核病院（救急対応）"
            ),
            UsefulInfo(
                id: "sado-convenience",
                category: .convenience,
                name: "両津港・相川・金井周辺",
                phoneNumber: nil,
                address: "両津港ターミナル・市街地",
                websiteURL: nil,
                note: "セブン-イレブン、ローソン、ゆうちょATMなど"
            ),
            UsefulInfo(
                id: "sado-tourism",
                category: .tourism,
                name: "佐渡観光協会",
                phoneNumber: "0259-27-5000",
                address: "新潟県佐渡市両津福浦723",
                websiteURL: "https://www.visitsado.com/",
                note: "観光案内・イベント情報"
            ),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            LiveCamera(
                title: "新潟県公式チャンネル（佐渡）",
                urlString: "https://www.youtube.com/@niigatapref"
            ),
            LiveCamera(
                title: "けえ【島育ち】（佐渡出身）",
                urlString: "https://www.youtube.com/@kee_sado"
            ),
        ],
        flightSchedules: [
            FlightAirlineSchedule(id: "sado-ana", airline: ana, trips: []),
        ],
        flightScheduleNote: nil,
    )
}
