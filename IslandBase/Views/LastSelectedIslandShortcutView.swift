//
//  LastSelectedIslandShortcutView.swift
//  Island Base
//
//  最近見た島へのコンパクトショートカット
//

import SwiftUI

struct LastSelectedIslandShortcutView: View {
    let island: Island

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private var backgroundAssetName: String {
        IslandCatalog.profile(for: island)?.backgroundAssetName ?? IslandCatalog.defaultBackgroundAssetName
    }

    var body: some View {
        NavigationLink(value: island) {
            VStack(spacing: 6) {
                Image(backgroundAssetName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: imageHeight)
                    .clipped()
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(island.primaryName(for: languageStore.mode))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(width: cardWidth, alignment: .leading)
            .padding(8)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(palette.cardBackground.opacity(0.92))
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(palette.cardBorder, lineWidth: 1)
                    }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(
            languageStore.t(.openIslandDetail(island.primaryName(for: languageStore.mode)))
        )
    }

    /// 諸島カード（RegionCoverCardView）と同じ幅
    private var cardWidth: CGFloat { 148 }
    private var imageHeight: CGFloat { 52 }
}

#Preview {
    NavigationStack {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                LastSelectedIslandShortcutView(island: IslandCatalog.islands[0])
                LastSelectedIslandShortcutView(island: IslandCatalog.islands[1])
            }
            .padding()
        }
    }
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
