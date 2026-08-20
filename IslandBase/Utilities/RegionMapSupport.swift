//
//  RegionMapSupport.swift
//  Island Base
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

    /// 起動時の基準画角（`japanHomeMapEnvelope` と同じ）
    static func japanOverviewRegion() -> MKCoordinateRegion {
        japanHomeMapEnvelope()
    }

    /// トップ地図のカメラ制限（起動画角と同じ範囲に固定。パン・ズームなし）
    static var japanMapCameraBounds: MapCameraBounds {
        let envelope = japanHomeMapEnvelope()
        let distance = cameraDistanceToFit(region: envelope, multiplier: 1.4)
        return MapCameraBounds(
            centerCoordinateBounds: envelope,
            minimumDistance: distance,
            maximumDistance: distance
        )
    }

    /// ホーム本図のピン座標。上書きがなければ登録島の平均（諸島の中心）
    static func homeMapPinCoordinate(for region: IslandRegion) -> CLLocationCoordinate2D {
        if let latitude = region.homeMap.pinLatitude, let longitude = region.homeMap.pinLongitude {
            return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }

        let islands = IslandCatalog.islands(forRegionID: region.id)
        guard islands.isEmpty == false else {
            return CLLocationCoordinate2D(latitude: 36.5, longitude: 137.5)
        }

        let latitude = islands.map(\.latitude).reduce(0, +) / Double(islands.count)
        let longitude = islands.map(\.longitude).reduce(0, +) / Double(islands.count)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    static func homeMapInsetCameraPosition(for region: IslandRegion) -> MapCameraPosition {
        .region(homeMapInsetRegion(for: region))
    }

    static func homeMapInsetCameraBounds(for region: IslandRegion) -> MapCameraBounds {
        let envelope = homeMapInsetRegion(for: region)
        let distance = cameraDistanceToFit(region: envelope, multiplier: 1.55)
        return MapCameraBounds(
            centerCoordinateBounds: envelope,
            minimumDistance: distance,
            maximumDistance: distance
        )
    }

    /// 別枠用の固定画角（島群＋ラベル用の余白）
    private static func homeMapInsetRegion(for region: IslandRegion) -> MKCoordinateRegion {
        boundingRegion(
            for: IslandCatalog.islands(forRegionID: region.id).map(\.coordinate),
            minimumPadding: 0.14,
            paddingRatio: 0.55
        )
    }

    /// ホーム本図の画角。別枠地域は含めず、本図ピンだけから計算する
    private static func japanHomeMapEnvelope() -> MKCoordinateRegion {
        let pins = IslandRegionCatalog.homeMapMainRegions.map(homeMapPinCoordinate(for:))
        guard pins.isEmpty == false else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 36.5, longitude: 137.5),
                span: MKCoordinateSpan(latitudeDelta: 8, longitudeDelta: 10)
            )
        }

        var minLat = pins.map(\.latitude).min() ?? 36.5
        var maxLat = pins.map(\.latitude).max() ?? 36.5
        var minLon = pins.map(\.longitude).min() ?? 137.5
        var maxLon = pins.map(\.longitude).max() ?? 137.5

        let latSpan = max(maxLat - minLat, 1.0)
        let lonSpan = max(maxLon - minLon, 1.0)

        // ラベル用の余白（別枠に出した遠方地域は入れない）
        minLat -= max(latSpan * 0.14, 0.9)
        maxLat += max(latSpan * 0.28, 1.1)
        minLon -= max(lonSpan * 0.16, 1.1)
        maxLon += max(lonSpan * 0.18, 1.2)

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: maxLat - minLat,
                longitudeDelta: maxLon - minLon
            )
        )
    }

    private static func cameraDistanceToFit(
        region: MKCoordinateRegion,
        multiplier: Double = 2.2
    ) -> CLLocationDistance {
        let latRadians = region.center.latitude * .pi / 180
        let latMeters = region.span.latitudeDelta * 111_000
        let lonMeters = region.span.longitudeDelta * 111_000 * max(cos(latRadians), 0.35)
        return max(latMeters, lonMeters) * multiplier
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
