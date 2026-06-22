//
//  IslandUserLocationMapView.swift
//  Island Now
//
//  島と現在地をミニマップで表示する
//

import CoreLocation
import MapKit
import SwiftUI

struct IslandUserLocationMapView: View {
    let island: Island
    let islandProfile: IslandProfile?
    let userCoordinate: CLLocationCoordinate2D?
    let authorizationStatus: CLAuthorizationStatus

    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Label("あなたの現在地", systemImage: "location.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(DetailCardTheme.accent)

            Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
                Annotation(island.nameJapanese, coordinate: island.coordinate) {
                    Image(systemName: "mountain.2.fill")
                        .font(.caption)
                        .padding(6)
                        .background(Circle().fill(DetailCardTheme.iconAccent.opacity(0.9)))
                        .foregroundStyle(.white)
                }

                if let port = islandProfile?.port {
                    Annotation(port.name, coordinate: port.coordinate) {
                        Image(systemName: "ferry.fill")
                            .font(.caption2)
                            .padding(5)
                            .background(Circle().fill(DetailCardTheme.accent.opacity(0.85)))
                            .foregroundStyle(.white)
                    }
                }

                if let userCoordinate {
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
            .mapStyle(.standard(elevation: .flat))
            .frame(height: 160)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(DetailCardTheme.cardBorder, lineWidth: 1)
            }
            .onAppear {
                updateCamera()
            }
            .onChange(of: userCoordinate?.latitude) { _, _ in
                updateCamera()
            }
            .onChange(of: userCoordinate?.longitude) { _, _ in
                updateCamera()
            }

            Text(statusText)
                .font(.caption)
                .foregroundStyle(DetailCardTheme.secondaryText)
        }
        .padding(14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DetailCardTheme.cardBackground.opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(DetailCardTheme.cardBorder, lineWidth: 1)
                }
        }
    }

    private var statusText: String {
        switch authorizationStatus {
        case .denied, .restricted:
            return "位置情報が許可されていません。設定から許可すると地図に表示されます。"
        case .notDetermined:
            return "位置情報の許可を確認しています…"
        default:
            break
        }

        guard let userCoordinate else {
            return "現在地を取得中…"
        }

        let distance = distanceFromIslandCenter(userCoordinate)
        let radius = islandProfile?.placeSearchRadiusMeters ?? 12_000

        if distance <= radius {
            if let portAccess = IslandCatalog.formattedPortAccess(from: userCoordinate, islandID: island.id) {
                return "島内にいます（\(portAccess)）"
            }
            return "島内にいます"
        }
        return "この島から \(IslandCatalog.formattedDistance(distance)) の位置にいます"
    }

    private func distanceFromIslandCenter(_ coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let islandLocation = CLLocation(latitude: island.latitude, longitude: island.longitude)
        return userLocation.distance(from: islandLocation)
    }

    private func updateCamera() {
        cameraPosition = .region(mapRegion())
    }

    private func mapRegion() -> MKCoordinateRegion {
        var coordinates = [island.coordinate]
        if let port = islandProfile?.port {
            coordinates.append(port.coordinate)
        }
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

        let radius = islandProfile?.placeSearchRadiusMeters ?? 12_000
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

#Preview {
    IslandUserLocationMapView(
        island: IslandCatalog.islands[0],
        islandProfile: IslandCatalog.profile(for: "ishigaki"),
        userCoordinate: nil,
        authorizationStatus: .authorizedWhenInUse
    )
    .padding()
    .background(Color.black)
}
