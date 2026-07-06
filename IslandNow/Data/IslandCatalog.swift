//
//  IslandCatalog.swift
//  Island Now
//
//  アプリに登録されている島の一覧
//
//  【新しい島を追加するとき】
//  1. XxxIslandProfiles.swift など、地域ごとのファイルに IslandProfile を1つ追加
//  2. IslandCatalog.regionalProfiles にその地域の all を足す
//  3. 新地域なら IslandRegionCatalog に地域定義を追加
//  4. 背景画像があれば Assets.xcassets に imageset を追加
//

import CoreLocation
import Foundation

enum IslandCatalog {
    static let placeDisplayLimit = 20
    static let defaultBackgroundAssetName = "IslandBgIshigaki"

    private static let regionalProfiles: [[IslandProfile]] = [
        YaeyamaIslandProfiles.all,
        SadoIslandProfiles.all,
        IzuIslandProfiles.all,
        GotoIslandProfiles.all,
        KutsunaIslandProfiles.all,
        ShodoshimaNaoshimaIslandProfiles.all,
    ]

    static let all: [IslandProfile] = regionalProfiles.flatMap { $0 }

    static var islands: [Island] {
        all.map(\.island)
    }

    static var regions: [IslandRegion] {
        IslandRegionCatalog.all
    }

    static func profiles(forRegionID regionID: String) -> [IslandProfile] {
        all.filter { $0.regionID == regionID }
    }

    static func islands(forRegionID regionID: String) -> [Island] {
        profiles(forRegionID: regionID).map(\.island)
    }

    static func islandCount(forRegionID regionID: String) -> Int {
        profiles(forRegionID: regionID).count
    }

    static func profile(for islandID: String) -> IslandProfile? {
        all.first { $0.id == islandID }
    }

    static func profile(for island: Island) -> IslandProfile? {
        profile(for: island.id)
    }

    struct BackgroundCreditEntry: Identifiable {
        let islandID: String
        let islandNameJapanese: String
        let regionNameJapanese: String
        let credit: String

        var id: String { islandID }
    }

    /// 公開・法務向け：全島の背景画像クレジット一覧
    static var backgroundCreditEntries: [BackgroundCreditEntry] {
        all
            .map { profile in
                BackgroundCreditEntry(
                    islandID: profile.id,
                    islandNameJapanese: profile.island.nameJapanese,
                    regionNameJapanese: profile.regionDisplayName,
                    credit: profile.backgroundCredit
                )
            }
            .sorted { lhs, rhs in
                if lhs.regionNameJapanese != rhs.regionNameJapanese {
                    return lhs.regionNameJapanese < rhs.regionNameJapanese
                }
                return lhs.islandNameJapanese < rhs.islandNameJapanese
            }
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

    static func ports(for islandID: String) -> [IslandPort] {
        profile(for: islandID)?.ports ?? []
    }

    static func portAccessInfos(
        from coordinate: CLLocationCoordinate2D,
        islandID: String
    ) -> [PortAccessInfo] {
        guard let profile = profile(for: islandID), profile.ports.isEmpty == false else {
            return []
        }

        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let islandCenter = profile.island.coordinate

        return profile.ports
            .map { port in
                let portLocation = CLLocation(latitude: port.latitude, longitude: port.longitude)
                let meters = userLocation.distance(from: portLocation)
                let direction = PortDirectionHelper.directionLabel(
                    from: islandCenter,
                    to: port.coordinate
                )
                return PortAccessInfo(
                    port: port,
                    directionLabel: direction,
                    distanceMeters: meters
                )
            }
            .sorted { $0.distanceMeters < $1.distanceMeters }
    }

    static func ferryDataSourceNote(for islandID: String) -> String? {
        guard let regionID = profile(for: islandID)?.regionID else { return nil }
        return IslandRegionCatalog.region(for: regionID)?.ferryDataSourceNote
    }

    static func ferryValidUntilSuffix(for islandID: String) -> String? {
        guard let regionID = profile(for: islandID)?.regionID else { return nil }
        return IslandRegionCatalog.region(for: regionID)?.ferryValidUntilSuffix
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
        portAccessInfos(from: place.coordinate, islandID: islandID).first?.formattedLine
    }

    // 現在地から各港までの距離・徒歩時間（港名・方角付き）
    static func formattedPortAccess(from coordinate: CLLocationCoordinate2D, islandID: String) -> String? {
        let lines = portAccessInfos(from: coordinate, islandID: islandID).map(\.formattedLine)
        guard lines.isEmpty == false else { return nil }
        return lines.joined(separator: " / ")
    }

    static func formattedPortAccessLines(
        from coordinate: CLLocationCoordinate2D,
        islandID: String,
        includeWalkingTime: Bool = true
    ) -> [String] {
        portAccessInfos(from: coordinate, islandID: islandID).map {
            $0.formattedLine(includeWalkingTime: includeWalkingTime)
        }
    }
}
