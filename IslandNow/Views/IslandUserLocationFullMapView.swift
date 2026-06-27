//
//  IslandUserLocationFullMapView.swift
//  Island Now
//
//  島・港・現在地を全画面マップで表示する
//

import CoreLocation
import MapKit
import SwiftUI

struct IslandUserLocationFullMapView: View {
    let island: Island
    let islandProfile: IslandProfile?
    let userCoordinate: CLLocationCoordinate2D?
    let authorizationStatus: CLAuthorizationStatus

    @Environment(\.detailPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition = .automatic

    var body: some View {
        ZStack(alignment: .top) {
            mapContent

            returnBar
        }
        .background(Color.black)
    }

    private var mapContent: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom, .rotate]) {
            UserAnnotation()

            IslandUserLocationMapSupport.annotations(
                island: island,
                islandProfile: islandProfile,
                userCoordinate: userCoordinate,
                palette: palette,
                showsUserLocationAnnotation: false
            )
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
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

    // 地図操作でスワイプ戻りが効きにくいため、常に見える戻るボタンを置く
    private var returnBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Button {
                    dismiss()
                } label: {
                    Label("Island Now に戻る", systemImage: "xmark.circle.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.text)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.ultraThinMaterial, in: Capsule())
                }
                .buttonStyle(.plain)
                .accessibilityHint("島の詳細画面に戻ります")

                Spacer(minLength: 0)

                Text(island.nameJapanese)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial, in: Capsule())
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 10)
        }
        .frame(maxWidth: .infinity)
        .background {
            LinearGradient(
                colors: [Color.black.opacity(0.55), Color.black.opacity(0.0)],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)
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

#Preview {
    IslandUserLocationFullMapView(
        island: IslandCatalog.islands[0],
        islandProfile: IslandCatalog.profile(for: "ishigaki"),
        userCoordinate: nil,
        authorizationStatus: .authorizedWhenInUse
    )
}
