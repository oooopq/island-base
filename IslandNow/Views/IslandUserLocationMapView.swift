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

    private var locationViewModel: IslandUserLocationViewModel {
        IslandUserLocationViewModel(island: island, islandProfile: islandProfile)
    }

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
        let locationStatus = locationViewModel.status(for: userCoordinate)

        VStack(alignment: .leading, spacing: 4) {
            Text(locationStatus.summaryText)
                .font(.caption)
                .foregroundStyle(palette.secondaryText)

            if locationStatus.isOnIsland, locationStatus.portAccessLines.isEmpty == false {
                ForEach(Array(locationStatus.portAccessLines.enumerated()), id: \.offset) { _, line in
                    Text(line)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
            }
        }
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

#Preview("現在地取得中") {
    islandUserLocationMapPreview(userCoordinate: nil)
}

#Preview("島内") {
    islandUserLocationMapPreview(
        userCoordinate: CLLocationCoordinate2D(latitude: 24.337193, longitude: 124.155485)
    )
}

// 石垣島中心から約 287.9km（placeSearchRadiusMeters 18km 圏外）の座標
#Preview("島外 287.9km") {
    islandUserLocationMapPreview(
        userCoordinate: CLLocationCoordinate2D(latitude: 26.5, longitude: 125.932233)
    )
}

private func islandUserLocationMapPreview(
    userCoordinate: CLLocationCoordinate2D?,
    authorizationStatus: CLAuthorizationStatus = .authorizedWhenInUse
) -> some View {
    let profile = IslandCatalog.profile(for: "ishigaki")!
    return NavigationStack {
        IslandUserLocationMapView(
            island: profile.island,
            islandProfile: profile,
            userCoordinate: userCoordinate,
            authorizationStatus: authorizationStatus
        )
        .padding()
        .background(Color.black)
    }
}
