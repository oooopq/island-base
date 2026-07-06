//
//  PlacesSearchService.swift
//  Island Now
//
//  MapKit（Apple マップ）で島付近のスポットを検索する
//

import Foundation
import MapKit

struct PlacesSearchService {
    private let cacheKeyPrefix = "places_cache_v2_"

    // 島の座標付近でカテゴリに合うスポットを検索する
    func searchPlaces(for island: Island, category: PlaceCategory) async throws -> [PlaceInfo] {
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

        saveCache(sortedPlaces, islandID: island.id, category: category)
        return sortedPlaces
    }

    // オフライン用：最後に取得したスポット一覧を読み出す
    func cachedPlaces(for islandID: String, category: PlaceCategory) -> [PlaceInfo]? {
        let key = cacheKey(for: islandID, category: category)
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        guard let places = try? JSONDecoder().decode([PlaceInfo].self, from: data),
              places.isEmpty == false else {
            UserDefaults.standard.removeObject(forKey: key)
            return nil
        }

        return places
    }

    private func saveCache(_ places: [PlaceInfo], islandID: String, category: PlaceCategory) {
        guard places.isEmpty == false else { return }
        guard let data = try? JSONEncoder().encode(places) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey(for: islandID, category: category))
    }

    private func cacheKey(for islandID: String, category: PlaceCategory) -> String {
        cacheKeyPrefix + islandID + "_" + category.rawValue
    }
}

enum PlacesSearchError: Error {
    case noResults
}
