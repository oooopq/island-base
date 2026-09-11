//
//  FerryLinkSectionView.swift
//  Island Base
//
//  GTFS 非対応地域向け：各社公式サイトへのリンクのみ
//

import SwiftUI

struct FerryLinkSectionView: View {
    let companies: [FerryCompany]

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScheduleTransportHeaderView(
                kind: .ferry,
                title: languageStore.t(.ferry),
                subtitle: languageStore.t(.ferryAndHighSpeed)
            )

            Text(guidanceText)
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

    private var guidanceText: String {
        if companies.allSatisfy({ $0.name == "中島汽船" && usesInfoPageAndPhone($0) }) {
            return languageStore.t(.nakajimaKisenFerryGuidance)
        }
        return languageStore.t(.ferryCheckOfficialSites)
    }

    /// 公式サイトのトップ／運行状況がなく、案内ページと電話で完結する会社（中島汽船）
    private func usesInfoPageAndPhone(_ company: FerryCompany) -> Bool {
        company.homePageURL == nil
            && company.statusPageURL == nil
            && company.websiteLink != nil
            && company.phoneURL != nil
    }

    @ViewBuilder
    private func companyBlock(_ company: FerryCompany) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(companyTitle(company))
                .font(.subheadline)
                .fontWeight(.semibold)

            ScheduleOperatorActionButtonsView(
                actions: actions(for: company)
            )
        }
    }

    private func companyTitle(_ company: FerryCompany) -> String {
        if company.name == "中島汽船" {
            return languageStore.t(.nakajimaKisen)
        }
        return company.name
    }

    private func actions(for company: FerryCompany) -> [ScheduleOperatorAction] {
        if usesInfoPageAndPhone(company),
           let infoURL = company.websiteLink,
           let phoneURL = company.phoneURL {
            return [
                ScheduleOperatorAction(
                    id: "info-\(infoURL.absoluteString)",
                    title: languageStore.t(.routesAndTimetable),
                    systemImage: "calendar",
                    url: infoURL
                ),
                ScheduleOperatorAction(
                    id: "phone-\(company.phoneNumber)",
                    title: languageStore.t(.callToConfirm),
                    systemImage: "phone.fill",
                    url: phoneURL
                )
            ]
        }

        return company.linkButtons.map {
            ScheduleOperatorActionFactory.actions(for: $0, language: languageStore.mode)
        }
    }
}

#Preview {
    FerryLinkSectionView(
        companies: IslandCatalog.profile(for: "oshima")?.ferryLinkCompanies ?? []
    )
    .padding()
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
