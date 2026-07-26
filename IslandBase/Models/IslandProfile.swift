//
//  IslandProfile.swift
//  Island Base
//
//  1島ぶんの設定（座標・港・背景・フェリーなど）をまとめる
//

import CoreLocation
import Foundation

struct IslandPort: Identifiable {
    var id: String { name }
    let name: String
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// 天気API用の地点（地図用の島中心とは分離）
struct IslandWeatherLocation {
    /// 港・集落向けの標高補正（メートル）
    static let defaultPortElevationMeters: Double = 5

    let latitude: Double
    let longitude: Double
    /// Open-Meteo の標高補正（メートル）。港・集落向けに低標高を指定する
    let elevationMeters: Double?
    /// Open-Meteo `models`（例: jma_seamless）。nil なら自動選択
    let models: String?

    /// 港座標を天気地点にする（標高は低めに固定）
    static func from(
        port: IslandPort,
        elevationMeters: Double = defaultPortElevationMeters,
        models: String? = nil
    ) -> IslandWeatherLocation {
        IslandWeatherLocation(
            latitude: port.latitude,
            longitude: port.longitude,
            elevationMeters: elevationMeters,
            models: models
        )
    }
}

struct IslandProfile: Identifiable {
    static let defaultPlaceSearchRadiusMeters: CLLocationDistance = 12_000
    static let defaultOnIslandRadiusMeters: CLLocationDistance = 12_000

    let island: Island
    let regionID: String
    let ports: [IslandPort]
    /// 気象庁「海上警報・予報」の細分海域（島ごとに指定）
    let jmaMarineForecastArea: JMAMarineForecastArea
    /// 天気取得地点の上書き（nil なら先頭の港・低標高を使用）
    let weatherLocation: IslandWeatherLocation?
    let backgroundAssetName: String
    let backgroundCredit: String
    let placeSearchRadiusMeters: CLLocationDistance
    /// 現在地が「島内にいます」と判定される中心からの距離
    let onIslandRadiusMeters: CLLocationDistance
    /// 航路名・港名の判定用（例: 「石垣」「大原」）
    let routeKeywords: [String]
    let ferryGTFSFeeds: [FerryGTFSFeed]
    let sampleFerrySchedules: [FerryCompanySchedule]
    let usefulInfo: [UsefulInfo]
    let liveCameras: [LiveCamera]
    /// ライブカメラがない島向けの YouTube 関連リンク
    let youtubeRelatedLinks: [LiveCamera]
    let liveCameraFootnote: String?
    let flightSchedules: [FlightAirlineSchedule]
    let flightScheduleNote: String?
    /// 詳細画面を開いた直後のアート演出（nil で無効）
    let artIntro: IslandArtIntro?

    var id: String { island.id }

    var regionDisplayName: String {
        IslandRegionCatalog.displayName(for: regionID)
    }

    /// 八重山のみ OTTOP GTFS でアプリ内ダイヤを表示
    var usesFerryGTFS: Bool {
        ferryGTFSFeeds.isEmpty == false
    }

    /// アプリ内に発着時刻を出せるか（OTTOP GTFS のみ。代表ダイヤは出さない）
    var hasInAppFerryTrips: Bool {
        usesFerryGTFS
    }

    /// 時刻なし・公式リンクのみの島
    var showsFerryLinksOnly: Bool {
        hasInAppFerryTrips == false && ferryLinkCompanies.isEmpty == false
    }

    /// リンクのみ表示する地域向け：sampleFerrySchedules から会社を重複除去
    var ferryLinkCompanies: [FerryCompany] {
        var seen = Set<String>()
        var companies: [FerryCompany] = []

        for schedule in sampleFerrySchedules {
            let key = schedule.company.name
            guard seen.insert(key).inserted else { continue }
            companies.append(schedule.company)
        }

        return companies
    }

    /// アプリ内に航空便の発着時刻があるか（代表ダイヤは入れない）
    var hasInAppFlightTrips: Bool {
        flightSchedules.contains { $0.trips.isEmpty == false }
    }

    /// 航空便は公式リンクのみ
    var showsFlightLinksOnly: Bool {
        hasInAppFlightTrips == false && flightLinkAirlines.isEmpty == false
    }

    /// flightSchedules から航空会社を重複除去
    var flightLinkAirlines: [FlightAirline] {
        var seen = Set<String>()
        var airlines: [FlightAirline] = []

        for schedule in flightSchedules {
            let key = schedule.airline.name
            guard seen.insert(key).inserted else { continue }
            airlines.append(schedule.airline)
        }

        return airlines
    }

    /// 後方互換・単一港向け
    var port: IslandPort? {
        ports.first
    }

    /// 天気APIに送る地点（明示指定がなければ先頭の港）
    var resolvedWeatherLocation: IslandWeatherLocation? {
        if let weatherLocation {
            return weatherLocation
        }
        guard let port = ports.first else { return nil }
        return IslandWeatherLocation.from(port: port)
    }

    init(
        island: Island,
        regionID: String,
        ports: [IslandPort],
        jmaMarineForecastArea: JMAMarineForecastArea,
        weatherLocation: IslandWeatherLocation? = nil,
        backgroundAssetName: String,
        backgroundCredit: String,
        placeSearchRadiusMeters: CLLocationDistance,
        onIslandRadiusMeters: CLLocationDistance? = nil,
        routeKeywords: [String],
        ferryGTFSFeeds: [FerryGTFSFeed],
        sampleFerrySchedules: [FerryCompanySchedule],
        usefulInfo: [UsefulInfo],
        liveCameras: [LiveCamera],
        youtubeRelatedLinks: [LiveCamera] = [],
        liveCameraFootnote: String? = nil,
        flightSchedules: [FlightAirlineSchedule],
        flightScheduleNote: String?,
        artIntro: IslandArtIntro? = .fullscreenZoomOut
    ) {
        self.island = island
        self.regionID = regionID
        self.ports = ports
        self.jmaMarineForecastArea = jmaMarineForecastArea
        self.weatherLocation = weatherLocation
        self.backgroundAssetName = backgroundAssetName
        self.backgroundCredit = backgroundCredit
        self.placeSearchRadiusMeters = placeSearchRadiusMeters
        self.onIslandRadiusMeters = onIslandRadiusMeters ?? placeSearchRadiusMeters
        self.routeKeywords = routeKeywords
        self.ferryGTFSFeeds = ferryGTFSFeeds
        self.sampleFerrySchedules = sampleFerrySchedules
        self.usefulInfo = usefulInfo
        self.liveCameras = liveCameras
        self.youtubeRelatedLinks = youtubeRelatedLinks
        self.liveCameraFootnote = liveCameraFootnote
        self.flightSchedules = flightSchedules
        self.flightScheduleNote = flightScheduleNote
        self.artIntro = artIntro
    }

    func matchesRoute(_ routeLongName: String) -> Bool {
        routeKeywords.contains { routeLongName.contains($0) }
    }

    func matchesPlaceName(_ placeName: String) -> Bool {
        routeKeywords.contains { placeName.contains($0) }
    }

    func distanceMeters(from place: PlaceInfo) -> CLLocationDistance? {
        guard ports.isEmpty == false else { return nil }

        let placeLocation = CLLocation(latitude: place.latitude, longitude: place.longitude)
        let distances = ports.map { port in
            let portLocation = CLLocation(latitude: port.latitude, longitude: port.longitude)
            return placeLocation.distance(from: portLocation)
        }
        return distances.min()
    }
}
