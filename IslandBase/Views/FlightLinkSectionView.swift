//
//  FlightLinkSectionView.swift
//  Island Base
//
//  代表ダイヤを持たない地域向け：各航空会社の公式リンクのみ
//

import SwiftUI

struct FlightLinkSectionView: View {
    let airlines: [FlightAirline]

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScheduleTransportHeaderView(
                kind: .flight,
                title: languageStore.t(.flights)
            )

            Text(languageStore.t(.flightCheckOfficialSites))
                .font(.caption)
                .detailCardSecondaryText()
                .fixedSize(horizontal: false, vertical: true)

            ForEach(Array(airlines.enumerated()), id: \.element.name) { index, airline in
                airlineBlock(airline)

                if index < airlines.count - 1 {
                    Divider()
                }
            }
        }
        .detailSectionCard()
    }

    @ViewBuilder
    private func airlineBlock(_ airline: FlightAirline) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(airline.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            ScheduleOperatorActionButtonsView(
                actions: ScheduleOperatorActionFactory.actions(for: airline, language: languageStore.mode)
            )
        }
    }
}

#Preview {
    FlightLinkSectionView(
        airlines: IslandCatalog.profile(for: "kozushima")?.flightLinkAirlines ?? []
    )
    .padding()
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
