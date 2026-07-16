//
//  RegionHomeView.swift
//  Island Now
//
//  起動画面：日本地図から諸島郡を選ぶ
//

import MapKit
import SwiftUI

struct RegionHomeView: View {
    @Environment(\.detailPalette) private var palette
    @Environment(LastSelectedIslandStore.self) private var lastSelectedIslandStore
    @Environment(AppLanguageStore.self) private var languageStore
    @State private var cameraPosition: MapCameraPosition = RegionMapSupport.japanHomeCameraPosition()
    /// 地図ピンタップ用（Map 内の NavigationLink は実機で真っ暗になることがある）
    @State private var mapSelectedRegionID: String?

    var body: some View {
        GeometryReader { geometry in
            // 画面の約58%を地図に使い、諸島2列グリッドの余地も残す
            let mapHeight = max(320, min(geometry.size.height * 0.58, 560))

            ScrollView {
                VStack(spacing: 0) {
                    header
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        .padding(.bottom, 12)

                    japanMap(height: mapHeight)

                    regionChipGrid
                        .padding(.horizontal, 16)
                        .padding(.top, 10)
                        .padding(.bottom, 16)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(homeBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    ImageCreditsView()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(palette.secondaryText)
                }
                .accessibilityLabel(languageStore.t(.creditsAndSources))
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    AppLanguageToggleButton()
                    AppThemeToggleButton()
                }
            }
        }
        .navigationDestination(for: String.self) { regionID in
            if let region = IslandRegionCatalog.region(for: regionID) {
                RegionIslandsView(region: region)
            }
        }
        .navigationDestination(item: $mapSelectedRegionID) { regionID in
            if let region = IslandRegionCatalog.region(for: regionID) {
                RegionIslandsView(region: region)
            }
        }
        .navigationDestination(for: Island.self) { island in
            IslandDetailView(island: island)
        }
        .onAppear {
            applyJapanHomeCamera()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            if lastSelectedIslandStore.islands.isEmpty == false {
                recentIslandsSection
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(languageStore.t(.pickRegionOnMap))
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryText)

                Text(languageStore.t(.tapPinOrList))
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recentIslandsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageStore.t(.recentIslands))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(palette.secondaryText)

            HStack(spacing: 10) {
                ForEach(lastSelectedIslandStore.islands) { island in
                    LastSelectedIslandShortcutView(island: island)
                }
            }
        }
    }

    private func japanMap(height: CGFloat) -> some View {
        Map(
            position: $cameraPosition,
            bounds: RegionMapSupport.japanMapCameraBounds,
            interactionModes: [.pan, .zoom]
        ) {
            ForEach(IslandCatalog.regions) { region in
                Annotation("", coordinate: region.mapCoordinate) {
                    Button {
                        mapSelectedRegionID = region.id
                    } label: {
                        JapanRegionMarkerView(region: region)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(
                        "\(region.displayName(for: languageStore.mode)) \(languageStore.t(.islandCount(IslandCatalog.islandCount(forRegionID: region.id))))"
                    )
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .onAppear {
            applyJapanHomeCamera()
        }
        .task(id: height) {
            // 起動・レイアウト確定のたびに、全諸島が収まる基準画角へ戻す
            applyJapanHomeCamera()
            try? await Task.sleep(for: .milliseconds(50))
            applyJapanHomeCamera()
            try? await Task.sleep(for: .milliseconds(200))
            applyJapanHomeCamera()
        }
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }

    private func applyJapanHomeCamera() {
        cameraPosition = RegionMapSupport.japanHomeCameraPosition()
    }

    /// 横スクロール1列ではなく、2列で全地域を見せる
    private var regionChipGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
        ]

        return LazyVGrid(columns: columns, spacing: 10) {
            ForEach(IslandCatalog.regions) { region in
                NavigationLink(value: region.id) {
                    RegionChipView(region: region)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var homeBackground: some View {
        ZStack {
            Color(red: 0.06, green: 0.08, blue: 0.12)
            LinearGradient(
                colors: [
                    palette.cardBackground.opacity(0.35),
                    palette.cardBackground.opacity(0.85),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

private struct JapanRegionMarkerView: View {
    let region: IslandRegion

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private var islandCount: Int {
        IslandCatalog.islandCount(forRegionID: region.id)
    }

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "mountain.2.fill")
                .font(.caption)
                .padding(8)
                .background(Circle().fill(palette.iconAccent))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.25), radius: 4, y: 2)

            Text(region.mapLabel(for: languageStore.mode))
                .font(.caption2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .frame(maxWidth: 72)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(languageStore.t(.islandCount(islandCount)))
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(palette.cardBackground.opacity(0.9), in: Capsule())
        }
    }
}

private struct RegionChipView: View {
    let region: IslandRegion

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private var islandCount: Int {
        IslandCatalog.islandCount(forRegionID: region.id)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(region.displayName(for: languageStore.mode))
                .font(.subheadline)
                .fontWeight(.semibold)
                .lineLimit(2)
                .minimumScaleFactor(0.85)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 4)

            Text(languageStore.t(.islandCount(islandCount)))
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, minHeight: 48, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(palette.cardBorder, lineWidth: 1)
                }
        }
    }
}

#Preview {
    NavigationStack {
        RegionHomeView()
    }
    .environment(AppThemeStore())
    .environment(AppLanguageStore())
    .environment(LastSelectedIslandStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
