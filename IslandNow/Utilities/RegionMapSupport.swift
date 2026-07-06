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
    /// 未登録だが追加予定の地域（地図の可動範囲計算用）
    private static let plannedRegionAnchorCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 45.18, longitude: 141.18), // 利尻・礼文付近
        CLLocationCoordinate2D(latitude: 27.09, longitude: 142.19), // 小笠原（父島付近）
    ]

    static func japanHomeCameraPosition() -> MapCameraPosition {
        // .region なら MapKit が画面比率に合わせて諸島全体を収める（MapCamera より正確）
        .region(japanOverviewRegion())
    }

    /// 起動時：登録済み諸島郡をすべて収める日本全体ビュー
    static func japanOverviewRegion() -> MKCoordinateRegion {
        var region = boundingRegion(
            for: IslandRegionCatalog.all.map(\.mapCoordinate),
            minimumPadding: 2.5,
            paddingRatio: 0.50
        )

        // 八重山は最南端。Annotation のラベルが下に伸びるため、南側だけ余白を足す
        let extraSouthMarginDegrees = 1.0
        region.span.latitudeDelta += extraSouthMarginDegrees
        region.center.latitude -= extraSouthMarginDegrees / 2

        return region
    }

    /// トップ地図を日本周辺に留める（世界地図までズームアウトしない）
    static var japanMapCameraBounds: MapCameraBounds {
        let coordinates = IslandRegionCatalog.all.map(\.mapCoordinate) + plannedRegionAnchorCoordinates
        let centerBounds = boundingRegion(
            for: coordinates,
            minimumPadding: 3.0,
            paddingRatio: 0.55
        )
        // 起動時 .region のズームより狭くしない（狭いと北側が切れて南寄りに見える）
        let overviewDistance = cameraDistanceToFit(region: japanOverviewRegion())
        let boundsDistance = cameraDistanceToFit(region: centerBounds)

        return MapCameraBounds(
            centerCoordinateBounds: centerBounds,
            maximumDistance: max(overviewDistance, boundsDistance) * 1.35
        )
    }

    /// リージョンの span から、地図全体が収まるカメラ距離（メートル）を概算
    private static func cameraDistanceToFit(region: MKCoordinateRegion) -> CLLocationDistance {
        let latRadians = region.center.latitude * .pi / 180
        let latMeters = region.span.latitudeDelta * 111_000
        let lonMeters = region.span.longitudeDelta * 111_000 * max(cos(latRadians), 0.35)
        return max(latMeters, lonMeters) * 1.55
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
