//
//  PlacesSearchService.swift
//  Island Base
//
//  MapKit（Apple マップ）で島付近のスポットを検索する
//

import Foundation
import MapKit

struct PlacesCacheEntry: Codable {
    let places: [PlaceInfo]
    /// 古いキャッシュ形式では nil
    let fetchedAt: Date?
}

struct PlacesSearchService {
    private let cacheKeyPrefix = "places_cache_v2_"

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

        let sortedPlaces = places.sorted { lhs, rhs in
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
