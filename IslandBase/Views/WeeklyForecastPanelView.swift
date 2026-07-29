//
//  WeeklyForecastPanelView.swift
//  Island Base
//
//  週間天気（固定高さフレーム内でスクロール）
//

import SwiftUI

struct WeeklyForecastPanelView: View {
    let forecast: [DailyWeatherForecast]

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private let rowHeight: CGFloat = 52
    private let visibleRowCount: CGFloat = 4

    private var panelMaxHeight: CGFloat {
        visibleRowCount * rowHeight
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(forecast.enumerated()), id: \.element.id) { index, day in
                    weeklyRow(day)

                    if index < forecast.count - 1 {
                        Divider()
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .frame(maxHeight: panelMaxHeight)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.chipBackground(isSelected: false))
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(languageStore.t(.weeklyWeatherAccessibility))
    }

    @ViewBuilder
    private func weeklyRow(_ day: DailyWeatherForecast) -> some View {
        HStack(spacing: 8) {
            Text(day.localizedDateLabel(language: languageStore.mode))
                .frame(width: 88, alignment: .leading)

            WeatherIconView(weatherCode: day.weatherCode, condition: day.condition, iconSize: 20)

            Text(day.localizedCondition(language: languageStore.mode))
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .trailing, spacing: 2) {
                Text("\(day.minTemperatureCelsius)° / \(day.maxTemperatureCelsius)°")
                Text("\(languageStore.t(.humidity)) \(day.humidityPercent)%")
                    .font(.caption)
                Label(
                    languageStore.t(.precipitationPercent(day.precipitationProbabilityPercent)),
                    systemImage: "drop.fill"
                )
                    .font(.caption)
            }
            .detailCardSecondaryText()
        }
        .font(.subheadline)
        .frame(minHeight: rowHeight, alignment: .center)
    }
}

#Preview {
    WeeklyForecastPanelView(
        forecast: (21...27).map { day in
            DailyWeatherForecast(
                id: "2026-06-\(day)",
                dateLabel: "6/\(day)（\(["月", "火", "水", "木", "金", "土", "日"][day - 21])）",
                minTemperatureCelsius: 24,
                maxTemperatureCelsius: 29,
                condition: day % 2 == 0 ? "晴れ" : "くもり",
                weatherCode: day % 2 == 0 ? 0 : 3,
                humidityPercent: 70,
                precipitationProbabilityPercent: 20
            )
        }
    )
    .padding()
    .environment(\.detailPalette, DetailCardPalette.dark)
    .environment(AppLanguageStore())
}
