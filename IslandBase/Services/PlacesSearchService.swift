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
    /// v5: 宿の自然言語検索に旅館・ゲストハウス・ペンションを追加
    private let cacheKeyPrefix = "places_cache_v5_"

    // 島付近でカテゴリに合うスポットを検索する
    func searchPlaces(for island: Island, category: PlaceCategory) async throws -> PlacesCacheEntry {
        let radius = IslandCatalog.profile(for: island.id)?.placeSearchRadiusMeters
            ?? IslandProfile.defaultPlaceSearchRadiusMeters
        let region = searchRegion(for: island, radius: radius)

        let poiItems = await fetchPOIItems(category: category, region: region)
        let queryItems = await fetchNaturalLanguageItems(
            category: category,
            island: island,
            region: region
        )

        let places = mergePlaces(
            poiItems + queryItems,
            categoryLabel: category.rawValue
        )

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

    private func searchRegion(for island: Island, radius: CLLocationDistance) -> MKCoordinateRegion {
        let ports = IslandCatalog.ports(for: island.id)
        let center: CLLocationCoordinate2D
        if ports.isEmpty {
            center = island.coordinate
        } else {
            let latitude = ports.map(\.latitude).reduce(0, +) / Double(ports.count)
            let longitude = ports.map(\.longitude).reduce(0, +) / Double(ports.count)
            center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        return MKCoordinateRegion(
            center: center,
            latitudinalMeters: radius,
            longitudinalMeters: radius
        )
    }

    private func fetchPOIItems(
        category: PlaceCategory,
        region: MKCoordinateRegion
    ) async -> [MKMapItem] {
        let request = MKLocalSearch.Request()
        request.region = region
        request.pointOfInterestFilter = MKPointOfInterestFilter(including: category.mapKitCategories)
        request.resultTypes = .pointOfInterest

        guard let response = try? await MKLocalSearch(request: request).start() else {
            return []
        }
        return response.mapItems
    }

    private func fetchNaturalLanguageItems(
        category: PlaceCategory,
        island: Island,
        region: MKCoordinateRegion
    ) async -> [MKMapItem] {
        var items: [MKMapItem] = []

        for query in category.naturalLanguageQueries(for: island) {
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = query
            request.region = region

            guard let response = try? await MKLocalSearch(request: request).start() else {
                continue
            }
            items.append(contentsOf: response.mapItems)
        }

        return items
    }

    private func mergePlaces(_ mapItems: [MKMapItem], categoryLabel: String) -> [PlaceInfo] {
        var seenKeys: Set<String> = []
        var places: [PlaceInfo] = []

        for mapItem in mapItems {
            guard let place = PlaceInfo.from(mapItem: mapItem, categoryLabel: categoryLabel) else {
                continue
            }
            let key = dedupeKey(for: place)
            guard seenKeys.contains(key) == false else { continue }
            seenKeys.insert(key)
            places.append(place)
        }

        return places
    }

    private func dedupeKey(for place: PlaceInfo) -> String {
        let lat = (place.latitude * 10_000).rounded() / 10_000
        let lon = (place.longitude * 10_000).rounded() / 10_000
        return "\(place.name)-\(lat)-\(lon)"
    }

    /// この島の店舗か（港からの距離で判定。離島同士の誤判定を減らす）
    private func belongsToIsland(
        _ place: PlaceInfo,
        island: Island,
        radius: CLLocationDistance
    ) -> Bool {
        let ports = IslandCatalog.ports(for: island.id)
        if ports.isEmpty {
            return belongsToIslandByCenter(place, island: island, radius: radius)
        }

        let nearestPortOnIsland = ports.map { place.distanceMeters(from: $0.coordinate) }.min()
        guard let nearestPortOnIsland, nearestPortOnIsland <= radius else {
            return false
        }

        guard let regionID = IslandCatalog.profile(for: island.id)?.regionID else {
            return true
        }

        let regionProfiles = IslandCatalog.profiles(forRegionID: regionID)
        guard regionProfiles.count > 1 else {
            return true
        }

        let nearestIslandID = nearestPortIslandID(for: place, profiles: regionProfiles)
        return nearestIslandID == island.id
    }

    /// 港がない島向けの従来ロジック（島中心＋最寄り島）
    private func belongsToIslandByCenter(
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

    /// 地域内の全港のうち、いちばん近い港がある島の ID
    private func nearestPortIslandID(for place: PlaceInfo, profiles: [IslandProfile]) -> String? {
        var nearestIslandID: String?
        var nearestDistance = CLLocationDistance.greatestFiniteMagnitude

        for profile in profiles {
            for port in profile.ports {
                let distance = place.distanceMeters(from: port.coordinate)
                if distance < nearestDistance {
                    nearestDistance = distance
                    nearestIslandID = profile.island.id
                }
            }
        }

        return nearestIslandID
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
