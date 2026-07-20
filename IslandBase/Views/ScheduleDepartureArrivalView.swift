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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            departureRow
            timeRow(time: arrivalTime, label: "着", labelColor: palette.secondaryText, isUrgent: false)
        }
    }

    private var departureRow: some View {
        timeRow(
            time: departureTime,
            label: "発",
            labelColor: isDepartureUrgent ? .red : palette.accent,
            isUrgent: isDepartureUrgent
        )
    }

    private func timeRow(time: String, label: String, labelColor: Color, isUrgent: Bool) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 10) {
            Text(time)
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
                .foregroundStyle(isUrgent ? .red : palette.text)

            Text(label == "発" ? "発" : "着")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(labelColor)

            if label == "着", NextDepartureHelper.isNextDayArrival(
                departureTime: departureTime,
                arrivalTime: arrivalTime
            ) {
                Text("翌日")
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
}
