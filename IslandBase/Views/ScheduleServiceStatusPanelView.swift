//
//  ScheduleServiceStatusPanelView.swift
//  Island Base
//
//  ダイヤタブ先頭の「運航状況」パネル（全島共通）
//  欠航・遅延の情報そのものはアプリに出さない。各社の公式ページへのリンクと電話だけを並べる
//

import SwiftUI

struct ScheduleServiceStatusPanelView: View {
    let ferryCompanies: [FerryCompany]
    let airlines: [FlightAirline]
    var marineForecastArea: JMAMarineForecastArea? = nil

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(languageStore.t(.serviceStatusPanelTitle))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(palette.warning)
            }

            Text(languageStore.t(.serviceStatusPanelNote))
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(rows) { row in
                operatorRow(row)
            }

            if let marineForecastArea {
                JMAMarineForecastLinkView(area: marineForecastArea)
            }
        }
        .scheduleStatusCallout()
    }

    /// 会社1つ分の行（種類アイコン＋会社名、その下に「運航状況 / 電話」ボタン）
    private func operatorRow(_ row: ServiceStatusRow) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label {
                Text(row.name)
                    .font(.caption)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: row.kind.systemImage)
                    .font(.caption)
                    .foregroundStyle(row.kind.accentColor)
            }

            ScheduleOperatorActionButtonsView(actions: row.actions)
        }
    }

    /// 船の会社 → 飛行機の会社の順。ボタンが1つも無い会社は行ごと出さない
    private var rows: [ServiceStatusRow] {
        let ferryRows = ferryCompanies.map { company in
            ServiceStatusRow(
                id: "ferry-\(company.name)",
                kind: .ferry,
                name: company.displayName(for: languageStore.mode),
                actions: ScheduleOperatorActionFactory.actions(
                    for: company,
                    kinds: ScheduleOperatorActionKind.panelKinds,
                    language: languageStore.mode
                )
            )
        }
        let flightRows = airlines.map { airline in
            ServiceStatusRow(
                id: "flight-\(airline.name)",
                kind: .flight,
                name: airline.displayName(for: languageStore.mode),
                actions: ScheduleOperatorActionFactory.actions(
                    for: airline,
                    kinds: ScheduleOperatorActionKind.panelKinds,
                    language: languageStore.mode
                )
            )
        }
        return (ferryRows + flightRows).filter { $0.actions.isEmpty == false }
    }
}

/// パネルの1行分（会社1つ）
private struct ServiceStatusRow: Identifiable {
    let id: String
    let kind: ScheduleTransportKind
    let name: String
    let actions: [ScheduleOperatorAction]
}

#Preview("Dark") {
    ScheduleServiceStatusPanelView(
        ferryCompanies: [
            FerryCompany(
                name: "東海汽船株式会社",
                nameEnglish: "Tokai Kisen Co., Ltd.",
                websiteURL: "https://www.tokaikisen.co.jp/boarding/timetable/",
                phoneNumber: "03-5472-9999",
                statusPageURL: "https://www.tokaikisen.co.jp/schedule/",
                homePageURL: "https://www.tokaikisen.co.jp/"
            ),
        ],
        airlines: [
            FlightAirline(
                name: "新中央航空",
                nameEnglish: "New Central Airservice Co., Ltd.",
                websiteURL: "https://central-air.co.jp/schedule-fee.html",
                phoneNumber: "042-548-0100",
                statusPageURL: "https://central-air.co.jp/status.html"
            ),
        ],
        marineForecastArea: .kantoSouth
    )
    .padding()
    .detailSectionCard()
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}

#Preview("Light") {
    ScheduleServiceStatusPanelView(
        ferryCompanies: [
            FerryCompany(
                name: "東海汽船株式会社",
                nameEnglish: "Tokai Kisen Co., Ltd.",
                websiteURL: "https://www.tokaikisen.co.jp/boarding/timetable/",
                phoneNumber: "03-5472-9999",
                statusPageURL: "https://www.tokaikisen.co.jp/schedule/",
                homePageURL: "https://www.tokaikisen.co.jp/"
            ),
        ],
        airlines: [
            FlightAirline(
                name: "新中央航空",
                nameEnglish: "New Central Airservice Co., Ltd.",
                websiteURL: "https://central-air.co.jp/schedule-fee.html",
                phoneNumber: "042-548-0100",
                statusPageURL: "https://central-air.co.jp/status.html"
            ),
        ],
        marineForecastArea: .kantoSouth
    )
    .padding()
    .detailSectionCard()
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.light)
}
