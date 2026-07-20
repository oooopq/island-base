//
//  PlacesSearchService.swift
//  Island Base
//
//  MapKit（Apple マップ）で島付近のスポットを検索する
//

import CoreLocation
import Foundation
import MapKit

struct PlacesCacheEntry: Codable {
    let places: [PlaceInfo]
    /// 古いキャッシュ形式では nil
    let fetchedAt: Date?
}

struct PlacesSearchService {
    /// v3: 最寄り島フィルタ後の結果をキャッシュする
    private let cacheKeyPrefix = "places_cache_v3_"

    // 島の座標付近でカテゴリに合うスポットを検索する
    func searchPlaces(for island: Island, category: PlaceCategory) async throws -> PlacesCacheEntry {
        let request = MKLocalSearch.Request()
        let radius = IslandCatalog.profile(for: island.id)?.placeSearchRadiusMeters
            ?? IslandProfile.defaultPlaceSearchRadiusMeters

        request.region = MKCoordinateRegion(
            center: island.coordinate,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category.mapKitCategories)
        request.resultTypes = .pointOfInterest

        let response = try await MKLocalSearch(request: request).start()

        let places = response.mapItems.compactMap { mapItem in
            PlaceInfo.from(mapItem: mapItem, categoryLabel: category.rawValue)
        }

        // 半径外・他島の店舗を除いてから近い順に並べる
        let filteredPlaces = places.filter { belongsToIsland($0, island: island, radius: radius) }
        let sortedPlaces = filteredPlaces.sorted { lhs, rhs in
            let lhsDistance = IslandCatalog.profile(for: island.id)?.distanceMeters(from: lhs)
                ?? lhs.distanceMeters(from: island)
            let rhsDistance = IslandCatalog.profile(for: island.id)?.distanceMeters(from: rhs)
                ?? rhs.distanceMeters(from: island)
            return lhsDistance < rhsDistance
        }

        let entry = PlacesCacheEntry(places: sortedPlaces, fetchedAt: Date())
        saveCache(entry, islandID: island.id, category: category)
        return entry
    }

    /// この島の店舗か（検索半径内 かつ 同地域で最寄りの島が今の島）
    private func belongsToIsland(
        _ place: PlaceInfo,
        island: Island,
        radius: CLLocationDistance
    ) -> Bool {
        guard place.distanceMeters(from: island) <= radius else {
            return false
        }

        guard let regionID = IslandCatalog.profile(for: island.id)?.regionID else {
            return true
        }

        let regionIslands = IslandCatalog.islands(forRegionID: regionID)
        guard regionIslands.count > 1 else {
            return true
        }

        let nearestIsland = regionIslands.min { lhs, rhs in
            place.distanceMeters(from: lhs) < place.distanceMeters(from: rhs)
        }
        return nearestIsland?.id == island.id
    }

    // オフライン用：最後に取得したスポット一覧を読み出す
    func cachedPlaces(for islandID: String, category: PlaceCategory) -> PlacesCacheEntry? {
        let key = cacheKey(for: islandID, category: category)
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        if let entry = try? JSONDecoder().decode(PlacesCacheEntry.self, from: data),
           entry.places.isEmpty == false {
            return entry
        }

        // 旧形式（配列のみ）も読めるようにする
        if let places = try? JSONDecoder().decode([PlaceInfo].self, from: data),
           places.isEmpty == false {
            return PlacesCacheEntry(places: places, fetchedAt: nil)
        }

        UserDefaults.standard.removeObject(forKey: key)
        return nil
    }

    private func saveCache(_ entry: PlacesCacheEntry, islandID: String, category: PlaceCategory) {
        guard entry.places.isEmpty == false else { return }
        guard let data = try? JSONEncoder().encode(entry) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey(for: islandID, category: category))
    }

    private func cacheKey(for islandID: String, category: PlaceCategory) -> String {
        cacheKeyPrefix + islandID + "_" + category.rawValue
    }
}

enum PlacesSearchError: Error {
    case noResults
}
