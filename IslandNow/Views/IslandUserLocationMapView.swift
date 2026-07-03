//
//  IslandUserLocationMapView.swift
//  Island Now
//
//  島と現在地をミニマップで表示する（タップで全画面マップへ）
//

import CoreLocation
import MapKit
import SwiftUI

struct IslandUserLocationMapView: View {
    let island: Island
    let islandProfile: IslandProfile?
    let userCoordinate: CLLocationCoordinate2D?
    let authorizationStatus: CLAuthorizationStatus

    @Environment(\.detailPalette) private var palette
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var showsFullMap = false

    private let miniMapHeight: CGFloat = 96

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("あなたの現在地", systemImage: "location.fill")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(palette.accent)

            Button {
                showsFullMap = true
            } label: {
                miniMapPreview
            }
            .buttonStyle(.plain)
            .accessibilityHint("タップすると地図を開いて現在地を表示します")

            portAccessStatusView
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(palette.cardBackground.opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(palette.cardBorder, lineWidth: 1)
                }
        }
        .fullScreenCover(isPresented: $showsFullMap) {
            IslandUserLocationFullMapView(
                island: island,
                islandProfile: islandProfile,
                userCoordinate: userCoordinate,
                authorizationStatus: authorizationStatus
            )
            .environment(\.detailPalette, palette)
        }
    }

    private var miniMapPreview: some View {
        Map(position: $cameraPosition, interactionModes: []) {
            IslandUserLocationMapSupport.annotations(
                island: island,
                islandProfile: islandProfile,
                userCoordinate: userCoordinate,
                palette: palette,
                showsUserLocationAnnotation: true
            )
        }
        .mapStyle(.standard(elevation: .flat))
        .frame(height: miniMapHeight)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
        .overlay(alignment: .bottomTrailing) {
            Label("地図で見る", systemImage: "arrow.up.left.and.arrow.down.right")
                .font(.caption2)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .foregroundStyle(.white)
                .background(.black.opacity(0.45), in: Capsule())
                .padding(8)
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
    }

    @ViewBuilder
    private var portAccessStatusView: some View {
        switch authorizationStatus {
        case .denied, .restricted:
            Text("位置情報が許可されていません。設定から許可すると地図に表示されます。")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)

        case .notDetermined:
            Text("位置情報の許可を確認しています…")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)

        default:
            if let userCoordinate {
                locationStatusContent(for: userCoordinate)
            } else {
                Text("現在地を取得中…")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
        }
    }

    @ViewBuilder
    private func locationStatusContent(for userCoordinate: CLLocationCoordinate2D) -> some View {
        let distance = distanceFromIslandCenter(userCoordinate)
        let radius = islandProfile?.onIslandRadiusMeters ?? IslandProfile.defaultOnIslandRadiusMeters
        let portLines = IslandCatalog.formattedPortAccessLines(
            from: userCoordinate,
            islandID: island.id
        )

        VStack(alignment: .leading, spacing: 4) {
            if distance <= radius {
                Text("島内にいます")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)

                if portLines.isEmpty {
                    EmptyView()
                } else {
                    ForEach(Array(portLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                    }
                }
            } else {
                Text("この島から \(IslandCatalog.formattedDistance(distance)) の位置にいます")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)

                if portLines.isEmpty == false {
                    ForEach(Array(portLines.enumerated()), id: \.offset) { _, line in
                        Text(line)
                            .font(.caption)
                            .foregroundStyle(palette.secondaryText)
                    }
                }
            }
        }
    }

    private func distanceFromIslandCenter(_ coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let islandLocation = CLLocation(latitude: island.latitude, longitude: island.longitude)
        return userLocation.distance(from: islandLocation)
    }

    private func updateCamera() {
        cameraPosition = .region(
            IslandUserLocationMapSupport.mapRegion(
                island: island,
                islandProfile: islandProfile,
                userCoordinate: userCoordinate
            )
        )
    }
}

#Preview {
    NavigationStack {
        IslandUserLocationMapView(
            island: IslandCatalog.islands[0],
            islandProfile: IslandCatalog.profile(for: "ishigaki"),
            userCoordinate: nil,
            authorizationStatus: .authorizedWhenInUse
        )
        .padding()
        .background(Color.black)
    }
}
