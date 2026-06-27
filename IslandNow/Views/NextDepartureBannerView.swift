//
//  NextDepartureBannerView.swift
//  Island Now
//
//  「次の便」を強調表示するバナー
//

import SwiftUI

struct NextDepartureBannerView: View {
    let title: String
    let departures: [UpcomingDeparture]
    let showsTomorrowNote: Bool

    @Environment(\.detailPalette) private var palette

    var body: some View {
        if departures.isEmpty == false {
            TimelineView(.periodic(from: .now, by: 60)) { _ in
                VStack(alignment: .leading, spacing: 10) {
                    Label(title, systemImage: "clock.fill")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.accent)

                    if showsTomorrowNote {
                        Text("本日の出港便は終了しました。翌日の最初の便です。")
                            .font(.caption)
                            .foregroundStyle(palette.warning)
                    }

                    ForEach(Array(departures.enumerated()), id: \.element.id) { index, departure in
                        if index > 0 {
                            Divider()
                        }
                        departureRow(departure)
                    }
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(palette.bannerBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    @ViewBuilder
    private func departureRow(_ departure: UpcomingDeparture) -> some View {
        let countdownMinutes = NextDepartureHelper.minutesUntilDeparture(
            departureTime: departure.departureTime,
            isTomorrow: showsTomorrowNote
        )
        let isUrgent = NextDepartureHelper.isDepartureUrgent(
            countdownMinutes: countdownMinutes,
            isTomorrow: showsTomorrowNote
        )

        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                Text(departure.routeText)
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScheduleDepartureArrivalView(
                    departureTime: departure.departureTime,
                    arrivalTime: departure.arrivalTime,
                    isDepartureUrgent: isUrgent
                )

                if let detailText = departure.detailText, detailText.isEmpty == false {
                    Text(detailText)
                        .font(.caption)
                        .detailCardSecondaryText()
                }
            }

            Spacer(minLength: 8)

            departureSummary(
                for: departure,
                countdownMinutes: countdownMinutes,
                isUrgent: isUrgent
            )
        }
    }

    @ViewBuilder
    private func departureSummary(
        for departure: UpcomingDeparture,
        countdownMinutes: Int?,
        isUrgent: Bool
    ) -> some View {
        let durationMinutes = NextDepartureHelper.travelDurationMinutes(
            departureTime: departure.departureTime,
            arrivalTime: departure.arrivalTime
        )
        let countdownColor: Color = isUrgent ? .red : palette.accent

        VStack(alignment: .trailing, spacing: 8) {
            if let countdownMinutes {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("あと")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(isUrgent ? .red : palette.secondaryText)

                    Text(NextDepartureHelper.formattedCountdown(countdownMinutes))
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                        .foregroundStyle(countdownColor)
                }
            }

            if let durationMinutes {
                VStack(alignment: .trailing, spacing: 2) {
                    Text("所要")
                        .font(.caption2)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.secondaryText)

                    Text(NextDepartureHelper.formattedDuration(durationMinutes))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .monospacedDigit()
                }
            }
        }
        .frame(minWidth: 72, alignment: .trailing)
    }
}
