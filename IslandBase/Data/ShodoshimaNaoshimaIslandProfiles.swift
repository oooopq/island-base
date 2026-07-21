//
//  ShodoshimaNaoshimaIslandProfiles.swift
//  Island Base
//
//  小豆島・直島諸島の島データ（小豆島・直島・豊島・犬島）
//  島中心座標: OpenStreetMap 島ポリゴン重心。港座標: OSM ferry_terminal / pier。
//

import Foundation

enum ShodoshimaNaoshimaIslandProfiles {
    static let all: [IslandProfile] = [
        shodoshima,
        naoshima,
        teshima,
        inujima,
    ]

    // MARK: - 共有データ

    private static let shikokuFerry = FerryCompany(
        name: "四国フェリー株式会社",
        websiteURL: "https://www.shikokuferry.com/lp-ferry/",
        phoneNumber: "087-851-0131",
        statusPageURL: "https://www.shikokuferry.com/news/",
        homePageURL: "https://www.shikokuferry.com/"
    )

    private static let shodoshimaFerry = FerryCompany(
        name: "小豆島豊島フェリー株式会社",
        websiteURL: "https://www.shodoshima-ferry.co.jp/timetable/",
        phoneNumber: "0879-62-1348",
        statusPageURL: "https://www.shodoshima-ferry.co.jp/",
        homePageURL: "https://www.shodoshima-ferry.co.jp/"
    )

    private static let shikokuKisen = FerryCompany(
        name: "四国汽船株式会社",
        websiteURL: "https://www.shikokukisen.com/routes/",
        phoneNumber: "087-821-5100",
        statusPageURL: "https://www.shikokukisen.com/news/traffic-info/",
        homePageURL: "https://www.shikokukisen.com/"
    )

    private static let akebonoMaritime = FerryCompany(
        name: "あけぼのマリタイム株式会社",
        websiteURL: "https://www.akebonomaritime.com/",
        phoneNumber: "086-947-1757",
        statusPageURL: "https://www.akebonomaritime.com/",
        homePageURL: "https://www.akebonomaritime.com/"
    )

    private static let setouchiTourismURL = "https://www.setouchi.travel/jp/"

    private static func setouchiLink(title: String) -> LiveCamera {
        LiveCamera(title: title, urlString: setouchiTourismURL)
    }

    /// 公式リンクのみ（trips 空 → FerryLinkSectionView 表示）
    private static func linkOnly(id: String, company: FerryCompany) -> FerryCompanySchedule {
        FerryCompanySchedule(id: id, company: company, trips: [])
    }

    // MARK: - 小豆島

    private static let shodoshimaPort = IslandPort(
        name: "土庄港",
        latitude: 34.489263,
        longitude: 134.171791
    )

    private static let shodoshima = IslandProfile(
        island: Island(
            id: "shodoshima",
            nameJapanese: "小豆島",
            nameEnglish: "Shodoshima",
            latitude: 34.489773,
            longitude: 134.253862
        ),
        regionID: "shodoshima_naoshima",
        ports: [shodoshimaPort],
        backgroundAssetName: "IslandBgShodoshima",
        backgroundCredit: "Photo: Yu / Unsplash（小豆島・香川）",
        placeSearchRadiusMeters: 20_000,
        onIslandRadiusMeters: 18_000,
        routeKeywords: ["小豆島", "土庄", "オリーブ"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            linkOnly(id: "shodoshima-shikoku-ferry", company: shikokuFerry),
            linkOnly(id: "shodoshima-local-ferry", company: shodoshimaFerry),
        ],
        usefulInfo: [
            UsefulInfo(
                id: "shodoshima-hospital",
                category: .medical,
                name: "小豆島中央病院",
                phoneNumber: "0879-75-1121",
                address: "香川県小豆郡小豆島町池田2060番地1",
                websiteURL: "https://scha.jp/",
                note: "小豆島の中核病院"
            ),
            UsefulInfo(
                id: "shodoshima-tourism",
                category: .tourism,
                name: "せとうち旅（公式）",
                phoneNumber: nil,
                address: nil,
                websiteURL: setouchiTourismURL,
                note: "オリーブ・寒霞渓などの観光案内"
            ),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            setouchiLink(title: "せとうち旅（小豆島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 直島

    private static let naoshima = IslandProfile(
        island: Island(
            id: "naoshima",
            nameJapanese: "直島",
            nameEnglish: "Naoshima",
            latitude: 34.460468,
            longitude: 133.988786
        ),
        regionID: "shodoshima_naoshima",
        ports: [
            // 港座標: OSM ferry_terminal / 直島港ターミナル（本村）
            IslandPort(name: "宮浦港", latitude: 34.456351, longitude: 133.974135),
            IslandPort(name: "本村港", latitude: 34.461600, longitude: 133.998143),
        ],
        backgroundAssetName: "IslandBgNaoshima",
        backgroundCredit: "Photo: Rahil Chadha / Unsplash（直島）",
        placeSearchRadiusMeters: 8_000,
        onIslandRadiusMeters: 6_000,
        routeKeywords: ["直島", "宮浦", "本村", "ベネッセ"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            linkOnly(id: "naoshima-shikoku-kisen", company: shikokuKisen),
            linkOnly(id: "naoshima-shodoshima-ferry", company: shodoshimaFerry),
        ],
        usefulInfo: [
            UsefulInfo(
                id: "naoshima-clinic",
                category: .medical,
                name: "直島診療所",
                phoneNumber: "0879-82-2211",
                address: "香川県小豆郡直島町",
                websiteURL: nil,
                note: "島内診療所（休診日あり）"
            ),
            UsefulInfo(
                id: "naoshima-tourism",
                category: .tourism,
                name: "直島（Benesse Art Site）",
                phoneNumber: "087-892-3222",
                address: nil,
                websiteURL: "https://benesse-artsite.jp/",
                note: "美術館・アートハウスプロジェクト"
            ),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            setouchiLink(title: "せとうち旅（直島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 豊島

    private static let teshima = IslandProfile(
        island: Island(
            id: "teshima",
            nameJapanese: "豊島",
            nameEnglish: "Teshima",
            latitude: 34.479685,
            longitude: 134.070243
        ),
        regionID: "shodoshima_naoshima",
        ports: [
            // 港座標: OSM ferry_terminal（家浦）/ 小豆島豊島フェリー唐櫃港FT（唐櫃）
            IslandPort(name: "家浦港", latitude: 34.490076, longitude: 134.060982),
            IslandPort(name: "唐櫃港", latitude: 34.489934, longitude: 134.095569),
        ],
        backgroundAssetName: "IslandBgTeshima",
        backgroundCredit: "Photo: Denis Kovalev / Unsplash（豊島・豊島美術館）",
        placeSearchRadiusMeters: 5_000,
        onIslandRadiusMeters: 4_000,
        routeKeywords: ["豊島", "家浦", "唐櫃", "テシマ"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            linkOnly(id: "teshima-shikoku-kisen", company: shikokuKisen),
            linkOnly(id: "teshima-shodoshima-ferry", company: shodoshimaFerry),
        ],
        usefulInfo: [
            UsefulInfo(
                id: "teshima-tourism",
                category: .tourism,
                name: "豊島（Benesse Art Site）",
                phoneNumber: "087-892-3222",
                address: nil,
                websiteURL: "https://benesse-artsite.jp/art/teshima-artmuseum.html",
                note: "豊島美術館・心臓音のアーカイブ"
            ),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            setouchiLink(title: "せとうち旅（豊島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )

    // MARK: - 犬島

    private static let inujima = IslandProfile(
        island: Island(
            id: "inujima",
            nameJapanese: "犬島",
            nameEnglish: "Inujima",
            latitude: 34.563578,
            longitude: 134.101092
        ),
        regionID: "shodoshima_naoshima",
        ports: [
            IslandPort(name: "犬島港", latitude: 34.566756, longitude: 134.104110),
        ],
        backgroundAssetName: "IslandBgInujima",
        backgroundCredit: "Photo: Tomoyuki Shidara / 犬島精錬所美術館（提供写真）",
        placeSearchRadiusMeters: 3_000,
        onIslandRadiusMeters: 2_500,
        routeKeywords: ["犬島", "犬島精錬所", "瀬戸内市"],
        ferryGTFSFeeds: [],
        sampleFerrySchedules: [
            linkOnly(id: "inujima-shikoku-kisen", company: shikokuKisen),
            linkOnly(id: "inujima-akebono", company: akebonoMaritime),
        ],
        usefulInfo: [
            UsefulInfo(
                id: "inujima-tourism",
                category: .tourism,
                name: "犬島精錬所美術館",
                phoneNumber: "087-892-3222",
                address: "香川県瀬戸内市犬島",
                websiteURL: "https://benesse-artsite.jp/island/inujima/",
                note: "直島・豊島経由または宝伝港から"
            ),
        ],
        liveCameras: [],
        youtubeRelatedLinks: [
            setouchiLink(title: "せとうち旅（犬島）"),
        ],
        flightSchedules: [],
        flightScheduleNote: nil,
    )
}
