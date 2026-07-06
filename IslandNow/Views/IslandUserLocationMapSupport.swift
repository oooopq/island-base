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
        showsUserLocationAnnotation: Bool,
        onIslandTap: (() -> Void)? = nil,
        onPortTap: ((IslandPort) -> Void)? = nil
    ) -> some MapContent {
        Annotation(island.nameJapanese, coordinate: island.coordinate) {
            if let onIslandTap {
                Button(action: onIslandTap) {
                    islandMarker(palette: palette)
                }
                .buttonStyle(.plain)
                .accessibilityHint("タップすると港を中心に島地図を表示します")
            } else {
                islandMarker(palette: palette)
            }
        }

        ForEach(islandProfile?.ports ?? []) { port in
            Annotation(port.name, coordinate: port.coordinate) {
                if let onPortTap {
                    Button {
                        onPortTap(port)
                    } label: {
                        portMarker(palette: palette)
                    }
                    .buttonStyle(.plain)
                    .accessibilityHint("\(port.name)を中心に島地図を表示します")
                } else {
                    portMarker(palette: palette)
                }
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

    private static func islandMarker(palette: DetailCardPalette) -> some View {
        Image(systemName: "mountain.2.fill")
            .font(.caption)
            .padding(6)
            .background(Circle().fill(palette.iconAccent.opacity(0.9)))
            .foregroundStyle(.white)
    }

    private static func portMarker(palette: DetailCardPalette) -> some View {
        Image(systemName: "ferry.fill")
            .font(.caption2)
            .padding(5)
            .background(Circle().fill(palette.accent.opacity(0.85)))
            .foregroundStyle(.white)
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

    /// 島＋港が収まる範囲（現在地は含めない）
    static func islandFitRegion(
        island: Island,
        islandProfile: IslandProfile?
    ) -> MKCoordinateRegion {
        mapRegion(island: island, islandProfile: islandProfile, userCoordinate: nil)
    }

    /// 全画面マップの初期表示（島周辺＋海）
    static func islandOverviewRegion(
        island: Island,
        islandProfile: IslandProfile?
    ) -> MKCoordinateRegion {
        let fit = islandFitRegion(island: island, islandProfile: islandProfile)

        return MKCoordinateRegion(
            center: fit.center,
            span: MKCoordinateSpan(
                latitudeDelta: fit.span.latitudeDelta * 4.0,
                longitudeDelta: fit.span.longitudeDelta * 4.0
            )
        )
    }

    /// 指定港を中心に、島全体が収まる範囲
    static func mapRegionCenteredOnPort(
        port: IslandPort,
        island: Island,
        islandProfile: IslandProfile?
    ) -> MKCoordinateRegion {
        let fit = islandFitRegion(island: island, islandProfile: islandProfile)

        return MKCoordinateRegion(
            center: port.coordinate,
            span: fit.span
        )
    }

    static func cameraDistance(for region: MKCoordinateRegion) -> CLLocationDistance {
        let latRadians = region.center.latitude * .pi / 180
        let latMeters = region.span.latitudeDelta * 111_000
        let lonMeters = region.span.longitudeDelta * 111_000 * max(cos(latRadians), 0.35)
        return max(latMeters, lonMeters) * 1.55
    }

    static func mapCamera(
        center: CLLocationCoordinate2D,
        distance: CLLocationDistance
    ) -> MapCamera {
        MapCamera(
            centerCoordinate: center,
            distance: distance,
            heading: 0,
            pitch: 0
        )
    }
}
