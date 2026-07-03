//
//  IslandUserLocationMapSupport.swift
//  Island Now
//
//  ミニマップ・全画面マップ共通の注釈と表示範囲
//

import CoreLocation
import MapKit
import SwiftUI

enum IslandUserLocationMapSupport {
    @MapContentBuilder
    static func annotations(
        island: Island,
        islandProfile: IslandProfile?,
        userCoordinate: CLLocationCoordinate2D?,
        palette: DetailCardPalette,
        showsUserLocationAnnotation: Bool
    ) -> some MapContent {
        Annotation(island.nameJapanese, coordinate: island.coordinate) {
            Image(systemName: "mountain.2.fill")
                .font(.caption)
                .padding(6)
                .background(Circle().fill(palette.iconAccent.opacity(0.9)))
                .foregroundStyle(.white)
        }

        ForEach(islandProfile?.ports ?? []) { port in
            Annotation(port.name, coordinate: port.coordinate) {
                Image(systemName: "ferry.fill")
                    .font(.caption2)
                    .padding(5)
                    .background(Circle().fill(palette.accent.opacity(0.85)))
                    .foregroundStyle(.white)
            }
        }

        if showsUserLocationAnnotation, let userCoordinate {
            Annotation("現在地", coordinate: userCoordinate) {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.25))
                        .frame(width: 28, height: 28)
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 12, height: 12)
                        .overlay {
                            Circle()
                                .strokeBorder(.white, lineWidth: 2)
                        }
                }
            }
        }
    }

    static func mapRegion(
        island: Island,
        islandProfile: IslandProfile?,
        userCoordinate: CLLocationCoordinate2D?
    ) -> MKCoordinateRegion {
        var coordinates = [island.coordinate]
        coordinates.append(contentsOf: (islandProfile?.ports ?? []).map(\.coordinate))
        if let userCoordinate {
            coordinates.append(userCoordinate)
        }

        let latitudes = coordinates.map(\.latitude)
        let longitudes = coordinates.map(\.longitude)
        let minLat = latitudes.min() ?? island.latitude
        let maxLat = latitudes.max() ?? island.latitude
        let minLon = longitudes.min() ?? island.longitude
        let maxLon = longitudes.max() ?? island.longitude

        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )

        let radius = islandProfile?.onIslandRadiusMeters ?? IslandProfile.defaultOnIslandRadiusMeters
        let minLatDelta = radius / 111_000
        let minLonDelta = radius / (111_000 * cos(center.latitude * .pi / 180))

        let latDelta = max(minLatDelta * 1.4, (maxLat - minLat) * 1.6 + minLatDelta * 0.3)
        let lonDelta = max(minLonDelta * 1.4, (maxLon - minLon) * 1.6 + minLonDelta * 0.3)

        return MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
}
