//
//  RegionIslandsView.swift
//  Island Base
//
//  諸島郡内の島一覧（地域マップ＋リスト）
//

import MapKit
import SwiftUI

struct RegionIslandsView: View {
    let region: IslandRegion

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedIsland: Island?

    private var islands: [Island] {
        IslandCatalog.islands(forRegionID: region.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                regionMap

                VStack(spacing: 10) {
                    ForEach(islands) { island in
                        Button {
                            selectedIsland = island
                        } label: {
                            IslandRowView(island: island)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(listBackground)
        .navigationTitle(region.displayName(for: languageStore.mode))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(item: $selectedIsland) { island in
            IslandDetailView(island: island)
        }
        .onAppear {
            cameraPosition = RegionMapSupport.cameraPosition(for: islands)
        }
    }

    private var regionMap: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            ForEach(islands) { island in
                Annotation(island.primaryName(for: languageStore.mode), coordinate: island.coordinate) {
                    Image(systemName: "mountain.2.fill")
                        .font(.caption)
                        .padding(6)
                        .background(Circle().fill(palette.iconAccent.opacity(0.9)))
                        .foregroundStyle(.white)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
        .allowsHitTesting(false)
    }

    private var listBackground: some View {
        palette.cardBackground.opacity(0.15)
            .ignoresSafeArea()
    }
}

private struct IslandRowView: View {
    let island: Island

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private var backgroundAssetName: String {
        IslandCatalog.profile(for: island)?.backgroundAssetName ?? IslandCatalog.defaultBackgroundAssetName
    }

    var body: some View {
        HStack(spacing: 14) {
            Image(backgroundAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: 64, height: 64)
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(island.primaryName(for: languageStore.mode))
                    .font(.headline)
                    .foregroundStyle(palette.text)

                Text(island.secondaryName(for: languageStore.mode).uppercased())
                    .font(.caption)
                    .tracking(1.2)
                    .foregroundStyle(palette.secondaryText)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(12)
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
        RegionIslandsView(region: IslandRegionCatalog.yaeyama)
    }
    .environment(AppThemeStore())
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
