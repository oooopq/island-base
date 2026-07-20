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
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

                Text(island.primaryName(for: languageStore.mode))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
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
}

#Preview {
    NavigationStack {
        HStack(spacing: 10) {
            LastSelectedIslandShortcutView(island: IslandCatalog.islands[0])
            LastSelectedIslandShortcutView(island: IslandCatalog.islands[1])
        }
        .padding()
    }
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
