//
//  IslandUserLocationViewModel.swift
//  Island Base
//
//  現在地カードの距離・島内外判定・表示文言を組み立てる
//

import CoreLocation
import Foundation

struct IslandUserLocationStatus {
    let isOnIsland: Bool
    let summaryText: String
    let portAccessLines: [String]
}

@MainActor
struct IslandUserLocationViewModel {
    let island: Island
    let islandProfile: IslandProfile?

    func status(for userCoordinate: CLLocationCoordinate2D, language: AppLanguageMode) -> IslandUserLocationStatus {
        let distanceFromCenter = distanceFromIslandCenter(from: userCoordinate)
        let onIslandRadius = islandProfile?.onIslandRadiusMeters ?? IslandProfile.defaultOnIslandRadiusMeters
        let isOnIsland = distanceFromCenter <= onIslandRadius

        if isOnIsland {
            return IslandUserLocationStatus(
                isOnIsland: true,
                summaryText: AppText.onIsland.string(for: language),
                portAccessLines: IslandCatalog.formattedPortAccessLines(
                    from: userCoordinate,
                    islandID: island.id,
                    includeWalkingTime: true,
                    language: language
                )
            )
        }

        return IslandUserLocationStatus(
            isOnIsland: false,
            summaryText: AppText.offIslandDistance(
                IslandCatalog.formattedDistance(distanceFromCenter)
            ).string(for: language),
            portAccessLines: []
        )
    }

    private func distanceFromIslandCenter(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let islandLocation = CLLocation(latitude: island.latitude, longitude: island.longitude)
        return userLocation.distance(from: islandLocation)
    }
}
