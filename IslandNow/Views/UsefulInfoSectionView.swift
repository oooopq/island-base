//
//  UsefulInfoSectionView.swift
//  Island Now
//
//  詳細画面のお役立ち情報セクション
//

import SwiftUI

struct UsefulInfoSectionView: View {
    let islandID: String

    @Environment(\.detailPalette) private var palette

    private var items: [UsefulInfo] {
        IslandCatalog.profile(for: islandID)?.usefulInfo ?? []
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("お役立ち情報")
                .font(.headline)

            ForEach(UsefulInfoCategory.allCases) { category in
                let categoryItems = items.filter { $0.category == category }
                if categoryItems.isEmpty == false {
                    categoryBlock(category: category, items: categoryItems)
                }
            }

            Text("※ 電話番号・診療時間は変更されている場合があります。緊急時は119（救急）・118（海上保安庁）")
                .font(.caption)
                .detailCardSecondaryText()
        }
        .detailSectionCard()
    }

    @ViewBuilder
    private func categoryBlock(category: UsefulInfoCategory, items: [UsefulInfo]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(category.rawValue, systemImage: category.systemImage)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(palette.accent)

            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Divider()
                }
                infoRow(item, category: category)
            }
        }
    }

    @ViewBuilder
    private func infoRow(_ item: UsefulInfo, category: UsefulInfoCategory) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: category.systemImage)
                .frame(width: 24)
                .foregroundStyle(palette.iconAccent)

            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if let address = item.address, address.isEmpty == false {
                    Text(address)
                        .font(.caption)
                        .detailCardSecondaryText()
                }

                if let phoneNumber = item.phoneNumber, phoneNumber.isEmpty == false {
                    Text(phoneNumber)
                        .font(.caption)
                        .detailCardSecondaryText()
                }

                if let note = item.note, note.isEmpty == false {
                    Text(note)
                        .font(.caption)
                        .detailCardSecondaryText()
                }
            }

            Spacer(minLength: 4)

            DetailRowLinkButtonsView(
                websiteURL: item.websiteLink,
                onNavigate: item.canOpenNavigation ? { item.openDrivingDirections() } : nil
            )
        }
    }
}

#Preview {
    UsefulInfoSectionView(islandID: "ishigaki")
        .padding()
}
