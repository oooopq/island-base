//
//  IslandDetailHeaderView.swift
//  Island Base
//
//  詳細画面の島名ヘッダー（コンパクト表示）
//

import SwiftUI

struct IslandDetailHeaderView: View {
    let island: Island
    let regionDisplayName: String?

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [palette.accent, palette.iconAccent],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 3, height: 38)

            VStack(alignment: .leading, spacing: 2) {
                if let regionDisplayName {
                    Text(regionDisplayName)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.accent)
                }

                Text(island.primaryName(for: languageStore.mode))
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundStyle(palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)

                Text(island.secondaryName(for: languageStore.mode).uppercased())
                    .font(.caption2)
                    .tracking(1.5)
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "mappin.and.ellipse")
                .font(.title3)
                .foregroundStyle(palette.accent.opacity(0.9))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.cardBackground.opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(palette.cardBorder, lineWidth: 1)
                }
        }
    }
}

#Preview {
    IslandDetailHeaderView(
        island: IslandCatalog.islands[0],
        regionDisplayName: "Yaeyama Islands"
    )
    .padding()
    .background(Color.black)
    .environment(AppLanguageStore())
}
