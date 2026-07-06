//
//  IslandUserLocationFullMapView.swift
//  Island Now
//
//  島・港・現在地を全画面マップで表示する（島/港アイコンタップで港中心にズーム）
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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dismiss) private var dismiss
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var currentCameraDistance: CLLocationDistance = 0
    @State private var zoomTask: Task<Void, Never>?

    private let zoomInDuration: TimeInterval = 0.45

    var body: some View {
        ZStack(alignment: .top) {
            mapContent

            returnBar
        }
        .background(Color.black)
        .onDisappear {
            zoomTask?.cancel()
        }
    }

    private var mapContent: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom, .rotate]) {
            UserAnnotation()

            IslandUserLocationMapSupport.annotations(
                island: island,
                islandProfile: islandProfile,
                userCoordinate: userCoordinate,
                palette: palette,
                showsUserLocationAnnotation: false,
                onIslandTap: { focusOnPrimaryPort() },
                onPortTap: { port in focusOnPort(port) }
            )
        }
        .mapStyle(.standard(elevation: .realistic))
        .mapControls {
            MapUserLocationButton()
            MapCompass()
            MapScaleView()
        }
        .onAppear {
            showOverview()
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

    private func showOverview() {
        let overview = IslandUserLocationMapSupport.islandOverviewRegion(
            island: island,
            islandProfile: islandProfile
        )
        currentCameraDistance = IslandUserLocationMapSupport.cameraDistance(for: overview)
        cameraPosition = .camera(
            IslandUserLocationMapSupport.mapCamera(
                center: overview.center,
                distance: currentCameraDistance
            )
        )
    }

    private func focusOnPrimaryPort() {
        guard let port = islandProfile?.ports.first else {
            focusOnPort(
                IslandPort(
                    name: island.nameJapanese,
                    latitude: island.latitude,
                    longitude: island.longitude
                )
            )
            return
        }

        focusOnPort(port)
    }

    private func focusOnPort(_ port: IslandPort) {
        zoomTask?.cancel()

        let targetRegion = IslandUserLocationMapSupport.mapRegionCenteredOnPort(
            port: port,
            island: island,
            islandProfile: islandProfile
        )
        let center = port.coordinate
        let targetDistance = IslandUserLocationMapSupport.cameraDistance(for: targetRegion)
        let startDistance = currentCameraDistance

        guard reduceMotion == false else {
            currentCameraDistance = targetDistance
            cameraPosition = .camera(
                IslandUserLocationMapSupport.mapCamera(center: center, distance: targetDistance)
            )
            return
        }

        zoomTask = Task { @MainActor in
            let steps = 16
            let stepSleep = zoomInDuration / Double(steps)

            for step in 1...steps {
                guard Task.isCancelled == false else { return }

                let progress = Double(step) / Double(steps)
                let eased = easeOut(progress)
                let distance = startDistance + (targetDistance - startDistance) * eased

                currentCameraDistance = distance
                cameraPosition = .camera(
                    IslandUserLocationMapSupport.mapCamera(center: center, distance: distance)
                )

                try? await Task.sleep(nanoseconds: UInt64(stepSleep * 1_000_000_000))
            }
        }
    }

    private func easeOut(_ progress: Double) -> Double {
        1 - pow(1 - progress, 3)
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
