//
//  SadoIslandProfiles.swift
//  Island Now
//
//  佐渡島の島データ
//

import Foundation

enum SadoIslandProfiles {
    static let all: [IslandProfile] = [
        sado,
    ]

    // MARK: - 共有データ

    private static let sadoKisen = FerryCompany(
        name: "佐渡汽船株式会社",
        websiteURL: "https://www.sadokisen.co.jp/",
        phoneNumber: "025-245-6400"
    )

    private static let ana = FlightAirline(
        name: "全日本空輸（ANA）",
        websiteURL: "https://www.ana.co.jp/",
        phoneNumber: "0570-029-222"
    )

    private static let sadoFlights: [FlightTrip] = [
        FlightTrip(id: "ana301", flightNumber: "ANA301", routeName: "新潟 → 佐渡", departureTime: "09:40", arrivalTime: "10:05"),
        FlightTrip(id: "ana303", flightNumber: "ANA303", routeName: "新潟 → 佐渡", departureTime: "15:10", arrivalTime: "15:35"),
        FlightTrip(id: "ana302", flightNumber: "ANA302", routeName: "佐渡 → 新潟", departureTime: "10:25", arrivalTime: "10:50"),
        FlightTrip(id: "ana304", flightNumber: "ANA304", routeName: "佐渡 → 新潟", departureTime: "15:55", arrivalTime: "16:20"),
    ]

    private static let flightScheduleNote = "代表ダイヤです。季節・天候により変更・欠航があります。"

    // MARK: - 佐渡島

    private static let sado = IslandProfile(
        island: Island(
            id: "sado",
            nameJapanese: "佐渡島",
            nameEnglish: "Sado",
            latitude: 38.0186,
            longitude: 138.3681
        ),
        regionID: "sado",
        ports: [IslandPort(name: "両津港", latitude: 38.0181, longitude: 138.2528)],
        backgroundAssetName: "IslandBgSado",
        backgroundCredit: "Photo: Unsplash（佐渡島・海と山）",
        placeSearchRadiusMeters: 18_000,
        routeKeywords: ["佐渡", "両津", "小木", "新潟", "直江津"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "sado-kisen-niigata",
                company: sadoKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "新潟 → 両津", departureTime: "06:00", arrivalTime: "07:30"),
                    FerryTrip(id: "2", routeName: "新潟 → 両津", departureTime: "10:00", arrivalTime: "11:30"),
                    FerryTrip(id: "3", routeName: "両津 → 新潟", departureTime: "08:00", arrivalTime: "09:30"),
                    FerryTrip(id: "4", routeName: "両津 → 新潟", departureTime: "17:00", arrivalTime: "18:30"),
                ]
            ),
            FerryCompanySchedule(
                id: "sado-kisen-naoetsu",
                company: sadoKisen,
                trips: [
                    FerryTrip(id: "1", routeName: "直江津 → 小木", departureTime: "07:30", arrivalTime: "09:00"),
                    FerryTrip(id: "2", routeName: "小木 → 直江津", departureTime: "16:00", arrivalTime: "17:30"),
                ]
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
        liveCameras: [
            LiveCamera(
                title: "佐渡観光ナビ（公式サイト）",
                urlString: "https://www.visitsado.com/"
            ),
            LiveCamera(
                title: "佐渡汽船（運航情報）",
                urlString: "https://www.sadokisen.co.jp/"
            ),
        ],
        flightSchedules: [
            FlightAirlineSchedule(id: "sado-ana", airline: ana, trips: sadoFlights),
        ],
        flightScheduleNote: flightScheduleNote
    )
}
