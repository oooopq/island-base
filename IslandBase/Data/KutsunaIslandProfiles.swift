//
//  KutsunaIslandProfiles.swift
//  Island Base
//
//  忽那諸島（くつなしょとう）の島データ — 有人9島
//  島中心座標: OpenStreetMap 島ポリゴン重心。港座標: OSM ferry_terminal/pier。
//

import Foundation

enum KutsunaIslandProfiles {
    static let all: [IslandProfile] = [
        nakajima,
        gogoshima,
        muzukijima,
        nogutsunajima,
        nuwajima,
        tsuwajishima,
        futagamijima,
        tsurushima,
        aijima,
    ]

    // MARK: - 共有データ

    private static let nakajimaKisen = FerryCompany(
        name: "中島汽船株式会社",
        websiteURL: "http://www.nakajimakisen.co.jp/",
        phoneNumber: "089-997-1221",
        statusPageURL: "http://www.nakajimakisen.co.jp/",
        homePageURL: "http://www.nakajimakisen.co.jp/"
    )

    private static let gogoshimaFerry = FerryCompany(
        name: "株式会社ごごしま",
        websiteURL: "https://gogoshima-ferry.com/",
        phoneNumber: "089-961-2034",
        statusPageURL: "https://gogoshima-ferry.com/information",
        homePageURL: "https://gogoshima-ferry.com/"
    )

    private static let aijimaShip = FerryCompany(
        name: "新喜峰（あいほく2）",
        websiteURL: "https://www.pref.ehime.jp/site/chuyo/4770.html",
        phoneNumber: "090-1174-2995",
        statusPageURL: "https://www.pref.ehime.jp/site/chuyo/4770.html",
        homePageURL: "https://www.pref.ehime.jp/site/chuyo/4770.html"
    )


    private static let kutsunaTourismURL = "https://ritou.ehime.jp/guide/kutsuna/"

    private static func kutsunaLink(title: String) -> LiveCamera {
        LiveCamera(title: title, urlString: kutsunaTourismURL)
    }

    // MARK: - 中島

    private static let nakajima = IslandProfile(
        island: Island(
            id: "nakajima",
            nameJapanese: "中島",
            nameEnglish: "Nakajima",
            latitude: 33.980615,
            longitude: 132.615204
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "大浦港", latitude: 33.973066, longitude: 132.630130),
            IslandPort(name: "神浦港", latitude: 33.949661, longitude: 132.603977),
            IslandPort(name: "西中港", latitude: 33.984307, longitude: 132.604786),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgNakajima",
        backgroundCredit: "Photo: melvil / Wikimedia Commons（中島・網明海岸）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 10_000,
        routeKeywords: ["中島", "大浦", "神浦", "忽那"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "nakajima-kisen-ferry-east",
                company: nakajimaKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "nakajima-kisen-hs-east",
                company: nakajimaKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "nakajima-hospital", category: .medical, name: "済生会松山病院（中島診療所）", phoneNumber: "089-997-1111", address: "愛媛県松山市中島大浦", websiteURL: nil, note: "島内の医療拠点"),
            UsefulInfo(id: "nakajima-tourism", category: .tourism, name: "忽那諸島観光（愛媛県）", phoneNumber: "089-948-6816", address: nil, websiteURL: kutsunaTourismURL, note: "姫ヶ浜・トライアスロン等"),
            UsefulInfo(id: "nakajima-convenience", category: .convenience, name: "大浦港・集落周辺", phoneNumber: nil, address: "大浦港ターミナル付近", websiteURL: nil, note: "スーパー・飲食店あり"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（中島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 興居島

    private static let gogoshima = IslandProfile(
        island: Island(
            id: "gogoshima",
            nameJapanese: "興居島",
            nameEnglish: "Gogoshima",
            latitude: 33.900000,
            longitude: 132.669444
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "由良港", latitude: 33.902807, longitude: 132.681645),
            IslandPort(name: "泊港", latitude: 33.882132, longitude: 132.680514),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgGogoshima",
        backgroundCredit: "Photo: Reggaeman / Wikimedia Commons（興居島）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 6_000,
        routeKeywords: ["興居", "興居島", "由良", "泊", "ごごしま"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "gogoshima-yura",
                company: gogoshimaFerry,
                trips: []
            ),
            FerryCompanySchedule(
                id: "gogoshima-toma",
                company: gogoshimaFerry,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "gogoshima-clinic", category: .medical, name: "興居島診療所", phoneNumber: "089-961-0315", address: "愛媛県松山市興居島", websiteURL: nil, note: "島内診療所"),
            UsefulInfo(id: "gogoshima-tourism", category: .tourism, name: "興居島へ行こう（ごごしま）", phoneNumber: "089-961-2034", address: nil, websiteURL: "https://gogoshima-ferry.com/", note: "小冨士山・船踊り等"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（興居島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 睦月島

    private static let muzukijima = IslandProfile(
        island: Island(
            id: "muzukijima",
            nameJapanese: "睦月島",
            nameEnglish: "Muzukijima",
            latitude: 33.962873,
            longitude: 132.661671
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "睦月港", latitude: 33.956442, longitude: 132.665515),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgMuzukijima",
        backgroundCredit: "Photo: melvil / Wikimedia Commons（睦月島）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 5_000,
        routeKeywords: ["睦月", "睦月島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "muzuki-kisen-ferry",
                company: nakajimaKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "muzuki-kisen-hs",
                company: nakajimaKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "muzuki-tourism", category: .tourism, name: "忽那諸島ガイド（睦月島）", phoneNumber: "089-948-6816", address: nil, websiteURL: kutsunaTourismURL, note: "古民家・島四国の案内"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（睦月島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 野忽那島

    private static let nogutsunajima = IslandProfile(
        island: Island(
            id: "nogutsunajima",
            nameJapanese: "野忽那島",
            nameEnglish: "Nogutsunajima",
            latitude: 33.971241,
            longitude: 132.689943
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "野忽那港", latitude: 33.975424, longitude: 132.688247),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgNogutsunajima",
        backgroundCredit: "Photo: 全樺連 / Wikimedia Commons（野忽那島）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 4_000,
        routeKeywords: ["野忽那", "野忽那島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "nogutsuna-kisen-ferry",
                company: nakajimaKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "nogutsuna-kisen-hs",
                company: nakajimaKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "nogutsuna-tourism", category: .tourism, name: "忽那諸島ガイド（野忽那島）", phoneNumber: "089-948-6816", address: nil, websiteURL: kutsunaTourismURL, note: "ヌカバ海水浴場・皿山"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（野忽那島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 怒和島

    private static let nuwajima = IslandProfile(
        island: Island(
            id: "nuwajima",
            nameJapanese: "怒和島",
            nameEnglish: "Nuwajima",
            latitude: 33.978187,
            longitude: 132.550265
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "上怒和港", latitude: 33.986633, longitude: 132.557480),
            IslandPort(name: "元怒和港", latitude: 33.974775, longitude: 132.540551),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgNuwajima",
        backgroundCredit: "Photo: 国土地理院 / Wikimedia Commons（怒和島・愛媛）／出典：国土地理院／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 5_000,
        routeKeywords: ["怒和", "怒和島", "上怒和", "元怒和"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "nuwa-kisen-ferry",
                company: nakajimaKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "nuwa-kisen-hs",
                company: nakajimaKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "nuwa-tourism", category: .tourism, name: "忽那諸島ガイド（怒和島）", phoneNumber: "089-948-6816", address: nil, websiteURL: kutsunaTourismURL, note: "クダコ水道・釣りスポット"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（怒和島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 津和地島

    private static let tsuwajishima = IslandProfile(
        island: Island(
            id: "tsuwajishima",
            nameJapanese: "津和地島",
            nameEnglish: "Tsuwajishima",
            latitude: 33.977649,
            longitude: 132.507031
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "津和地港", latitude: 33.983116, longitude: 132.516270),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgTsuwajishima",
        backgroundCredit: "Photo: 国土地理院 / Wikimedia Commons（津和地島・愛媛）／出典：国土地理院／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 4_000,
        routeKeywords: ["津和地", "津和地島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "tsuwaji-kisen-ferry",
                company: nakajimaKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "tsuwaji-kisen-hs",
                company: nakajimaKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "tsuwaji-tourism", category: .tourism, name: "忽那諸島ガイド（津和地島）", phoneNumber: "089-948-6816", address: nil, websiteURL: kutsunaTourismURL, note: "お茶屋跡・玉ねぎ・海の幸"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（津和地島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 二神島

    private static let futagamijima = IslandProfile(
        island: Island(
            id: "futagamijima",
            nameJapanese: "二神島",
            nameEnglish: "Futagamijima",
            latitude: 33.932082,
            longitude: 132.535200
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "二神港", latitude: 33.933428, longitude: 132.537155),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgFutagamijima",
        backgroundCredit: "Photo: 国土地理院 / Wikimedia Commons（二神島・愛媛）／出典：国土地理院／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 3_000,
        routeKeywords: ["二神", "二神島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "futagami-kisen-ferry",
                company: nakajimaKisen,
                trips: []
            ),
            FerryCompanySchedule(
                id: "futagami-kisen-hs",
                company: nakajimaKisen,
                trips: [],
                serviceKind: .highSpeedBoat
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "futagami-tourism", category: .tourism, name: "忽那諸島ガイド（二神島）", phoneNumber: "089-948-6816", address: nil, websiteURL: kutsunaTourismURL, note: "アラレガ浜・古民家"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（二神島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 釣島

    private static let tsurushima = IslandProfile(
        island: Island(
            id: "tsurushima",
            nameJapanese: "釣島",
            nameEnglish: "Tsurushima",
            latitude: 33.890817,
            longitude: 132.641526
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "釣島港", latitude: 33.894317, longitude: 132.639913),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgTsurushima",
        backgroundCredit: "Photo: Ka23 13 / Wikimedia Commons（釣島）／CC BY 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 2_000,
        routeKeywords: ["釣島", "釣"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "tsurushima-kisen-ferry",
                company: nakajimaKisen,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "tsurushima-tourism", category: .tourism, name: "忽那諸島ガイド（釣島）", phoneNumber: "089-948-6816", address: nil, websiteURL: kutsunaTourismURL, note: "釣島灯台・西線フェリーのみ"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（釣島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 安居島

    private static let aijima = IslandProfile(
        island: Island(
            id: "aijima",
            nameJapanese: "安居島",
            nameEnglish: "Aijima",
            latitude: 34.069597,
            longitude: 132.706998
        ),
        regionID: "kutsuna",
        ports: [
            IslandPort(name: "安居島港", latitude: 34.068059, longitude: 132.705669),
        ],
        jmaMarineForecastArea: .setonaikai,
        backgroundAssetName: "IslandBgAijima",
        backgroundCredit: "Photo: 全樺連 / Wikimedia Commons（安居島）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        placeSearchRadiusMeters: 2_000,
        routeKeywords: ["安居", "安居島"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            FerryCompanySchedule(
                id: "aijima-shinkiho",
                company: aijimaShip,
                trips: []
            ),
        ],
        usefulInfo: [
            UsefulInfo(id: "aijima-tourism", category: .tourism, name: "しまの魅力 安居島（愛媛県）", phoneNumber: "089-948-6816", address: nil, websiteURL: "https://www.pref.ehime.jp/site/chuyo/4770.html", note: "北条港から便数少・日帰りは曜日限定"),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            kutsunaLink(title: "忽那諸島ガイド（安居島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )
}
