//
//  RegionCoverCardView.swift
//  Island Base
//
//  ホーム画面の諸島群カード（カバー写真＋短い名前）
//

import SwiftUI

struct RegionCoverCardView: View {
    let region: IslandRegion

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private var islandCount: Int {
        IslandCatalog.islandCount(forRegionID: region.id)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(region.coverAssetName)
                .resizable()
                .scaledToFill()
                .frame(width: cardWidth, height: imageHeight)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

            Text(region.mapLabel(for: languageStore.mode))
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(palette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.85)

            Text(languageStore.t(.islandCount(islandCount)))
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .frame(width: cardWidth, alignment: .leading)
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.cardBackground.opacity(0.92))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(palette.cardBorder, lineWidth: 1)
                }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "\(region.displayName(for: languageStore.mode)) \(languageStore.t(.islandCount(islandCount)))"
        )
    }

    private var cardWidth: CGFloat { 148 }
    private var imageHeight: CGFloat { 88 }
}

#Preview {
    ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
            ForEach(IslandCatalog.regions) { region in
                RegionCoverCardView(region: region)
            }
        }
        .padding()
    }
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
