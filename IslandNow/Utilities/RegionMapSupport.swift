//
//  RegionMapSupport.swift
//  Island Now
//
//  諸島郡マップの表示範囲
//

import CoreLocation
import MapKit
import SwiftUI

enum RegionMapSupport {
    static func japanHomeCameraPosition() -> MapCameraPosition {
        .region(japanOverviewRegion())
    }

    static func japanOverviewRegion() -> MKCoordinateRegion {
        boundingRegion(
            for: IslandRegionCatalog.all.map(\.mapCoordinate),
            minimumPadding: 2.0,
            paddingRatio: 0.45
        )
    }

    static func cameraPosition(for islands: [Island]) -> MapCameraPosition {
        .region(region(for: islands))
    }

    static func region(for islands: [Island]) -> MKCoordinateRegion {
        boundingRegion(
            for: islands.map(\.coordinate),
            minimumPadding: 0.08,
            paddingRatio: 0.35
        )
    }

    private static func boundingRegion(
        for coordinates: [CLLocationCoordinate2D],
        minimumPadding: Double,
        paddingRatio: Double
    ) -> MKCoordinateRegion {
        guard coordinates.isEmpty == false else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.5, longitude: 137.5),
                span: MKCoordinateSpan(latitudeDelta: 1, longitudeDelta: 1)
            )
        }

        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLon = coordinates[0].longitude
        var maxLon = coordinates[0].longitude

        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLon = min(minLon, coordinate.longitude)
            maxLon = max(maxLon, coordinate.longitude)
        }

        let latPadding = max((maxLat - minLat) * paddingRatio, minimumPadding)
        let lonPadding = max((maxLon - minLon) * paddingRatio, minimumPadding)

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: (maxLat - minLat) + latPadding,
                longitudeDelta: (maxLon - minLon) + lonPadding
            )
        )
    }
}
