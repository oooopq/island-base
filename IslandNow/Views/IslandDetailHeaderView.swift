//
//  IslandDetailHeaderView.swift
//  Island Now
//
//  詳細画面の島名ヘッダー（どの島か一目で分かる表示）
//

import SwiftUI

struct IslandDetailHeaderView: View {
    let island: Island
    let regionID: String?

    private var regionLabel: String? {
        guard let regionID else { return nil }
        switch regionID {
        case "yaeyama":
            return "八重山諸島"
        case "sado":
            return "佐渡"
        default:
            return regionID
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            RoundedRectangle(cornerRadius: 2, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [DetailCardTheme.accent, DetailCardTheme.iconAccent],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 4)
                .shadow(color: DetailCardTheme.accent.opacity(0.6), radius: 6)

            VStack(alignment: .leading, spacing: 4) {
                if let regionLabel {
                    Text(regionLabel)
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .tracking(1.5)
                        .foregroundStyle(DetailCardTheme.accent)
                }

                Text(island.nameJapanese)
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .minimumScaleFactor(0.8)
                    .lineLimit(1)

                Text(island.nameEnglish.uppercased())
                    .font(.caption)
                    .fontWeight(.medium)
                    .tracking(3)
                    .foregroundStyle(DetailCardTheme.secondaryText)
            }

            Spacer(minLength: 0)

            Image(systemName: "mappin.and.ellipse")
                .font(.title2)
                .foregroundStyle(DetailCardTheme.accent.opacity(0.85))
                .shadow(color: DetailCardTheme.accent.opacity(0.5), radius: 8)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(DetailCardTheme.cardBackground.opacity(0.95))
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    DetailCardTheme.accent.opacity(0.45),
                                    DetailCardTheme.cardBorder,
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
                .shadow(color: .black.opacity(0.35), radius: 10, y: 4)
        }
    }
}

#Preview {
    IslandDetailHeaderView(
        island: IslandCatalog.islands[0],
        regionID: "yaeyama"
    )
    .padding()
    .background(Color.black)
}
