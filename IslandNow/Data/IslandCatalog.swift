//
//  IslandCatalog.swift
//  Island Now
//
//  アプリに登録されている島の一覧
//
//  【新しい島を追加するとき】
//  1. YaeyamaIslandProfiles.swift など、地域ごとのファイルに IslandProfile を1つ追加
//  2. 下の all 配列にその地域のプロファイルを足す
//  3. 背景画像があれば Assets.xcassets に imageset を追加
//

import CoreLocation
import Foundation

enum IslandCatalog {
    static let placeDisplayLimit = 20

    static let all: [IslandProfile] = YaeyamaIslandProfiles.all + SadoIslandProfiles.all

    static var islands: [Island] {
        all.map(\.island)
    }

    static func profile(for islandID: String) -> IslandProfile? {
        all.first { $0.id == islandID }
    }

    static func profile(for island: Island) -> IslandProfile? {
        profile(for: island.id)
    }

    static func islandID(matchingPlaceName placeName: String) -> String? {
        all.first { $0.matchesPlaceName(placeName) }?.id
    }

    static func displayName(for islandID: String) -> String {
        profile(for: islandID)?.island.nameJapanese ?? islandID
    }

    static func port(for islandID: String) -> IslandPort? {
        profile(for: islandID)?.port
    }

    static func formattedDistance(_ meters: CLLocationDistance) -> String {
        if meters < 1000 {
            return "\(Int(meters.rounded()))m"
        }
        return String(format: "%.1fkm", meters / 1000)
    }

    private static let walkingSpeedMetersPerMinute: Double = 80

    static func formattedWalkingTime(_ meters: CLLocationDistance) -> String {
        let minutes = max(1, Int((meters / walkingSpeedMetersPerMinute).rounded()))
        if minutes < 60 {
            return "徒歩約\(minutes)分"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if remainingMinutes == 0 {
            return "徒歩約\(hours)時間"
        }
        return "徒歩約\(hours)時間\(remainingMinutes)分"
    }

    static func formattedPortAccess(from place: PlaceInfo, islandID: String) -> String? {
        guard let meters = profile(for: islandID)?.distanceMeters(from: place) else { return nil }
        return "\(formattedDistance(meters))（\(formattedWalkingTime(meters))）"
    }

    // 現在地から港までの距離・徒歩時間（港名付き）
    static func formattedPortAccess(from coordinate: CLLocationCoordinate2D, islandID: String) -> String? {
        guard let port = port(for: islandID) else { return nil }

        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let portLocation = CLLocation(latitude: port.latitude, longitude: port.longitude)
        let meters = userLocation.distance(from: portLocation)

        return "\(port.name)から \(formattedDistance(meters))（\(formattedWalkingTime(meters))）"
    }
}
