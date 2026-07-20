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
    /// 未登録だが追加予定の地域（パン余白の北・東用。起動ズームには使わない）
    private static let plannedRegionAnchorCoordinates: [CLLocationCoordinate2D] = [
        CLLocationCoordinate2D(latitude: 45.18, longitude: 141.18), // 利尻・礼文付近
        CLLocationCoordinate2D(latitude: 27.09, longitude: 142.19), // 小笠原（父島付近）
    ]

    static func japanHomeCameraPosition() -> MapCameraPosition {
        .region(japanOverviewRegion())
    }

    /// 起動時の基準画角：八重山〜佐渡〜伊豆の全ピンが同時に見える日本概観
    /// （北回帰線が南端付近、韓国・上海が西側に少し入る程度）
    static func japanOverviewRegion() -> MKCoordinateRegion {
        let pins = IslandRegionCatalog.all.map(\.mapCoordinate)
        let fitted = boundingRegion(
            for: pins,
            minimumPadding: 1.2,
            paddingRatio: 0.18
        )

        // ピン範囲をベースに、参考スクショに近い余白へ広げる
        // 南: 北回帰線〜フィリピン海ラベル付近 / 北: 北海道南〜ウラジオ付近
        // 西: 上海・ソウルが端に入る / 東: 伊豆の東に少し余白
        var minLat = pins.map(\.latitude).min() ?? fitted.center.latitude
        var maxLat = pins.map(\.latitude).max() ?? fitted.center.latitude
        var minLon = pins.map(\.longitude).min() ?? fitted.center.longitude
        var maxLon = pins.map(\.longitude).max() ?? fitted.center.longitude

        minLat -= 1.8 // 八重山ラベル＋北回帰線付近
        maxLat += 5.5 // 佐渡より北
        minLon -= 5.5 // 大陸側
        maxLon += 2.5 // 伊豆より東

        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(
                latitude: (minLat + maxLat) / 2,
                longitude: (minLon + maxLon) / 2
            ),
            span: MKCoordinateSpan(
                latitudeDelta: max(maxLat - minLat, 18),
                longitudeDelta: max(maxLon - minLon, 16)
            )
        )
    }

    /// トップ地図のパン／ズーム制限（起動画角は必ず許可する）
    static var japanMapCameraBounds: MapCameraBounds {
        let overview = japanOverviewRegion()
        let panCoordinates = IslandRegionCatalog.all.map(\.mapCoordinate) + plannedRegionAnchorCoordinates
        var panBounds = boundingRegion(
            for: panCoordinates,
            minimumPadding: 2.0,
            paddingRatio: 0.35
        )
        // 起動画角の中心・スパンが bounds に収まるよう、少なくとも overview 以上の範囲にする
        panBounds = unionRegions(panBounds, overview)

        let overviewDistance = cameraDistanceToFit(region: overview)
        return MapCameraBounds(
            centerCoordinateBounds: panBounds,
            minimumDistance: overviewDistance * 0.15,
            // 縦長画面で overview 全体を映せるよう十分な上限
            maximumDistance: overviewDistance * 3.0
        )
    }

    private static func unionRegions(
        _ a: MKCoordinateRegion,
        _ b: MKCoordinateRegion
    ) -> MKCoordinateRegion {
        let aMinLat = a.center.latitude - a.span.latitudeDelta / 2
        let aMaxLat = a.center.latitude + a.span.latitudeDelta / 2
        let aMinLon = a.center.longitude - a.span.longitudeDelta / 2
        let aMaxLon = a.center.longitude + a.span.longitudeDelta / 2
        let bMinLat = b.center.latitude - b.span.latitudeDelta / 2
        let bMaxLat = b.center.latitude + b.span.latitudeDelta / 2
        let bMinLon = b.center.longitude - b.span.longitudeDelta / 2
        let bMaxLon = b.center.longitude + b.span.longitudeDelta / 2

        let minLat = min(aMinLat, bMinLat)
        let maxLat = max(aMaxLat, bMaxLat)
        let minLon = min(aMinLon, bMinLon)
        let maxLon = max(aMaxLon, bMaxLon)

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

    private static func cameraDistanceToFit(region: MKCoordinateRegion) -> CLLocationDistance {
        let latRadians = region.center.latitude * .pi / 180
        let latMeters = region.span.latitudeDelta * 111_000
        let lonMeters = region.span.longitudeDelta * 111_000 * max(cos(latRadians), 0.35)
        return max(latMeters, lonMeters) * 2.2
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
