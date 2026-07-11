//
//  FerryLinkSectionView.swift
//  Island Now
//
//  GTFS 非対応地域向け：各社公式サイトへのリンクのみ
//

import SwiftUI

struct FerryLinkSectionView: View {
    let companies: [FerryCompany]

    @Environment(\.detailPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("船便")
                    .font(.headline)
                Text("フェリー・高速船")
                    .font(.caption)
                    .detailCardSecondaryText()
            }

            Text("ダイヤ・運航状況は各社公式サイトでご確認ください。")
                .font(.caption)
                .detailCardSecondaryText()
                .fixedSize(horizontal: false, vertical: true)

            ForEach(Array(companies.enumerated()), id: \.element.name) { index, company in
                companyBlock(company)

                if index < companies.count - 1 {
                    Divider()
                }
            }
        }
        .detailSectionCard()
    }

    @ViewBuilder
    private func companyBlock(_ company: FerryCompany) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(company.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            ScheduleOperatorActionButtonsView(
                actions: company.linkButtons.map(ScheduleOperatorActionFactory.actions(for:))
            )
        }
    }
}

#Preview {
    FerryLinkSectionView(
        companies: IslandCatalog.profile(for: "oshima")?.ferryLinkCompanies ?? []
    )
    .padding()
    .environment(\.detailPalette, DetailCardPalette.dark)
}
