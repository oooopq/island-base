//
//  ScheduleDepartureArrivalView.swift
//  Island Base
//
//  ダイヤの発着時刻（縦並び・大きく表示）
//

import SwiftUI

struct ScheduleDepartureArrivalView: View {
    let departureTime: String
    let arrivalTime: String
    var isDepartureUrgent: Bool = false

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            departureRow
            timeRow(
                time: arrivalTime,
                label: languageStore.t(.scheduleArrivalShort),
                labelColor: palette.secondaryText,
                isUrgent: false,
                isDeparture: false
            )
        }
    }

    private var departureRow: some View {
        timeRow(
            time: departureTime,
            label: languageStore.t(.scheduleDepartureShort),
            labelColor: isDepartureUrgent ? .red : palette.accent,
            isUrgent: isDepartureUrgent,
            isDeparture: true
        )
    }

    private func timeRow(
        time: String,
        label: String,
        labelColor: Color,
        isUrgent: Bool,
        isDeparture: Bool
    ) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(time)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(isUrgent ? .red : palette.text)

            Text(label)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(labelColor)

            if isDeparture == false,
               NextDepartureHelper.isNextDayArrival(
                departureTime: departureTime,
                arrivalTime: arrivalTime
            ) {
                Text(languageStore.t(.nextDayArrival))
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.warning)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        ScheduleDepartureArrivalView(departureTime: "08:30", arrivalTime: "09:20")
        ScheduleDepartureArrivalView(departureTime: "08:30", arrivalTime: "09:20", isDepartureUrgent: true)
    }
    .padding()
    .detailSectionCard()
    .environment(AppLanguageStore())
}
