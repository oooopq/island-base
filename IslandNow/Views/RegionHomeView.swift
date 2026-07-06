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
    @State private var cameraPosition: MapCameraPosition = RegionMapSupport.japanHomeCameraPosition()
    /// 地図ピンタップ用（Map 内の NavigationLink は実機で真っ暗になることがある）
    @State private var mapSelectedRegionID: String?

    var body: some View {
        VStack(spacing: 0) {
            header
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 12)

            japanMap

            regionChipBar
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
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
                .accessibilityLabel("クレジット・出典")
            }

            ToolbarItem(placement: .topBarTrailing) {
                AppThemeToggleButton()
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
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 12) {
                AppBrandTitleView(style: .hero)

                Spacer(minLength: 8)

                if let island = lastSelectedIslandStore.island {
                    LastSelectedIslandShortcutView(island: island)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("行きたい諸島を地図から選んでください")
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryText)

                Text("ピンまたは下の一覧をタップ")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText.opacity(0.85))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var japanMap: some View {
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
                    .accessibilityLabel("\(region.displayNameJapanese) \(IslandCatalog.islandCount(forRegionID: region.id))島")
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .onAppear {
            // bounds 付き Map は初回レイアウト後に region を再適用しないと南寄りになることがある
            cameraPosition = RegionMapSupport.japanHomeCameraPosition()
        }
        .frame(minHeight: 280)
        .frame(maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
        .padding(.horizontal, 16)
    }

    private var regionChipBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(IslandCatalog.regions) { region in
                    NavigationLink(value: region.id) {
                        RegionChipView(region: region)
                    }
                    .buttonStyle(.plain)
                }
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

            Text(region.displayNameJapanese)
                .font(.caption2)
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .frame(maxWidth: 88)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text("\(islandCount)島")
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

    private var islandCount: Int {
        IslandCatalog.islandCount(forRegionID: region.id)
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(region.displayNameJapanese)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text("\(islandCount)島")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
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
    .environment(LastSelectedIslandStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
