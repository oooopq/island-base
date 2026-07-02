//
//  IslandProfile.swift
//  Island Now
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

struct IslandProfile: Identifiable {
    static let defaultPlaceSearchRadiusMeters: CLLocationDistance = 12_000
    static let defaultOnIslandRadiusMeters: CLLocationDistance = 12_000

    let island: Island
    let regionID: String
    let ports: [IslandPort]
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

    var id: String { island.id }

    var regionDisplayName: String {
        IslandRegionCatalog.displayName(for: regionID)
    }

    /// 八重山のみ OTTOP GTFS でアプリ内ダイヤを表示
    var usesFerryGTFS: Bool {
        ferryGTFSFeeds.isEmpty == false
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

    /// 後方互換・単一港向け
    var port: IslandPort? {
        ports.first
    }

    init(
        island: Island,
        regionID: String,
        ports: [IslandPort],
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
        flightScheduleNote: String?
    ) {
        self.island = island
        self.regionID = regionID
        self.ports = ports
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
