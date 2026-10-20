//
//  IslandCatalog.swift
//  Island Base
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
        let islandNameEnglish: String
        let regionNameJapanese: String
        let regionNameEnglish: String
        let credit: String
        let creditEnglish: String?

        var id: String { islandID }

        func credit(for language: AppLanguageMode) -> String {
            if language.isJapanese {
                return credit
            }
            return creditEnglish ?? credit
        }

        func islandName(for language: AppLanguageMode) -> String {
            language.isJapanese ? islandNameJapanese : islandNameEnglish
        }

        func regionName(for language: AppLanguageMode) -> String {
            language.isJapanese ? regionNameJapanese : regionNameEnglish
        }
    }

    /// 公開・法務向け：全島の背景画像クレジット一覧
    static var backgroundCreditEntries: [BackgroundCreditEntry] {
        all
            .map { profile in
                BackgroundCreditEntry(
                    islandID: profile.id,
                    islandNameJapanese: profile.island.nameJapanese,
                    islandNameEnglish: profile.island.nameEnglish,
                    regionNameJapanese: profile.regionDisplayName,
                    regionNameEnglish: IslandRegionCatalog.displayName(
                        for: profile.regionID,
                        language: .english
                    ),
                    credit: profile.backgroundCredit,
                    creditEnglish: profile.backgroundCreditEnglish
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

    static func displayName(for islandID: String, language: AppLanguageMode = .japanese) -> String {
        guard let island = profile(for: islandID)?.island else { return islandID }
        return island.primaryName(for: language)
    }

    /// 日本語の港名から `IslandPort.nameEnglish` を引く。別表は持たない。無い名前はそのまま。
    static func localizedPlaceName(_ japaneseName: String, language: AppLanguageMode) -> String {
        guard language == .english else { return japaneseName }

        if let port = all.lazy.compactMap({ profile in
            profile.ports.first { $0.name == japaneseName }
        }).first {
            return port.displayName(for: language)
        }

        if let island = all.first(where: { $0.island.nameJapanese == japaneseName })?.island {
            return island.primaryName(for: language)
        }

        if let endpoint = FlightEndpointCatalog.all.first(where: { $0.nameJapanese == japaneseName }) {
            return endpoint.displayName(for: language)
        }

        return japaneseName
    }

    /// 「石垣港 → 竹富港」の各停を英語名にする。照合用の保存文字列は日本語のまま。
    static func localizedRouteName(_ routeName: String, language: AppLanguageMode) -> String {
        guard language == .english else { return routeName }
        guard let route = FerryRouteHelper.parseRoute(routeName) else {
            return localizedPlaceName(routeName, language: language)
        }
        let departure = localizedPlaceName(route.departure, language: language)
        let arrival = localizedPlaceName(route.arrival, language: language)
        return "\(departure) → \(arrival)"
    }

    static func port(for islandID: String) -> IslandPort? {
        profile(for: islandID)?.port
    }

    static func ports(for islandID: String) -> [IslandPort] {
        profile(for: islandID)?.ports ?? []
    }

    static func portAccessInfos(
        from coordinate: CLLocationCoordinate2D,
        islandID: String,
        language: AppLanguageMode = .japanese
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
                    to: port.coordinate,
                    language: language
                )
                return PortAccessInfo(
                    port: port,
                    directionLabel: direction,
                    distanceMeters: meters
                )
            }
            .sorted { $0.distanceMeters < $1.distanceMeters }
    }

    static func ferryDataSourceNote(for islandID: String, language: AppLanguageMode = .japanese) -> String? {
        guard let regionID = profile(for: islandID)?.regionID else { return nil }
        return IslandRegionCatalog.region(for: regionID)?.ferryDataSourceNote(for: language)
    }

    static func ferryValidUntilSuffix(for islandID: String, language: AppLanguageMode = .japanese) -> String? {
        guard let regionID = profile(for: islandID)?.regionID else { return nil }
        return IslandRegionCatalog.region(for: regionID)?.ferryValidUntilSuffix(for: language)
    }

    static func formattedDistance(_ meters: CLLocationDistance) -> String {
        if meters < 1000 {
            return "\(Int(meters.rounded()))m"
        }
        return String(format: "%.1fkm", meters / 1000)
    }

    /// 英語の距離文用。日本語の `formattedDistance`（「1.2km」）は変えない。
    static func formattedDistanceEnglish(_ meters: CLLocationDistance) -> String {
        if meters < 1000 {
            return "\(Int(meters.rounded())) m"
        }
        return String(format: "%.1f km", meters / 1000)
    }

    private static let walkingSpeedMetersPerMinute: Double = 80

    static func formattedWalkingTime(
        _ meters: CLLocationDistance,
        language: AppLanguageMode = .japanese
    ) -> String {
        let minutes = max(1, Int((meters / walkingSpeedMetersPerMinute).rounded()))
        if language == .english {
            if minutes < 60 {
                return "about \(minutes) min walk"
            }
            let hours = minutes / 60
            let remainingMinutes = minutes % 60
            if remainingMinutes == 0 {
                return "about \(hours) hr walk"
            }
            return "about \(hours) hr \(remainingMinutes) min walk"
        }

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

    static func formattedPortAccess(
        from place: PlaceInfo,
        islandID: String,
        language: AppLanguageMode = .japanese
    ) -> String? {
        portAccessInfos(from: place.coordinate, islandID: islandID, language: language)
            .first?
            .formattedLine(includeWalkingTime: true, language: language)
    }

    // 現在地から各港までの距離・徒歩時間（港名・方角付き）
    static func formattedPortAccess(
        from coordinate: CLLocationCoordinate2D,
        islandID: String,
        language: AppLanguageMode = .japanese
    ) -> String? {
        let lines = portAccessInfos(from: coordinate, islandID: islandID, language: language).map {
            $0.formattedLine(includeWalkingTime: true, language: language)
        }
        guard lines.isEmpty == false else { return nil }
        return lines.joined(separator: " / ")
    }

    static func formattedPortAccessLines(
        from coordinate: CLLocationCoordinate2D,
        islandID: String,
        includeWalkingTime: Bool = true,
        language: AppLanguageMode = .japanese
    ) -> [String] {
        portAccessInfos(from: coordinate, islandID: islandID, language: language).map {
            $0.formattedLine(includeWalkingTime: includeWalkingTime, language: language)
        }
    }
}
