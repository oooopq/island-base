//
//  WeatherSectionView.swift
//  Island Now
//
//  詳細画面の天気セクション（現在＋1週間予報）
//

import SwiftUI

struct WeatherSectionView: View {
    let state: WeatherLoadState
    let heatStrokeState: HeatStrokeRiskLoadState

    @Environment(\.detailPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("天気")
                .font(.headline)

            switch state {
            case .loading:
                ProgressView("天気を取得中…")
                    .tint(palette.accent)
                    .detailCardSecondaryText()
                heatStrokeRiskContent

            case .loaded(let weather, let isFromCache):
                currentWeatherContent(weather)
                heatStrokeRiskContent
                todayHourlyForecastContent(weather.todayHourlyForecast)
                weeklyForecastContent(weather.weeklyForecast)
                if isFromCache {
                    Text("前回取得したデータを表示中")
                        .font(.caption)
                        .detailCardSecondaryText()
                }

            case .failed(let message, let cachedWeather):
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(palette.warning)
                if let cachedWeather {
                    currentWeatherContent(cachedWeather)
                    heatStrokeRiskContent
                    todayHourlyForecastContent(cachedWeather.todayHourlyForecast)
                    weeklyForecastContent(cachedWeather.weeklyForecast)
                    Text("オフライン用の保存データです")
                        .font(.caption)
                        .detailCardSecondaryText()
                } else {
                    heatStrokeRiskContent
                }
            }
        }
        .detailSectionCard()
    }

    @ViewBuilder
    private func currentWeatherContent(_ weather: WeatherInfo) -> some View {
        Text("現在")
            .font(.subheadline)
            .detailCardSecondaryText()

        HStack(alignment: .center, spacing: 16) {
            WeatherIconView(condition: weather.condition, iconSize: 56)

            VStack(alignment: .leading, spacing: 4) {
                Text("\(weather.temperatureCelsius)°C")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(weather.condition)
                    .font(.title3)

                Label("湿度 \(weather.humidityPercent)%", systemImage: "humidity")
                    .font(.subheadline)
                    .detailCardSecondaryText()
            }
        }

        Label("風速 \(formattedWindSpeedMs(kmh: weather.windSpeedKmh)) m/s", systemImage: "wind")
            .font(.subheadline)
            .detailCardSecondaryText()
    }

    // km/h を m/s に変換して表示用に整形する（小数点1桁）
    private func formattedWindSpeedMs(kmh: Int) -> String {
        let metersPerSecond = Double(kmh) / 3.6
        return String(format: "%.1f", metersPerSecond)
    }

    @ViewBuilder
    private var heatStrokeRiskContent: some View {
        switch heatStrokeState {
        case .unavailable:
            EmptyView()
        case .loading, .loaded, .failed:
            VStack(alignment: .leading, spacing: 8) {
                Divider()
                    .padding(.vertical, 4)

                Text("熱中症リスク（WBGT）")
                    .font(.subheadline)
                    .detailCardSecondaryText()

                switch heatStrokeState {
                case .loading:
                    ProgressView("WBGTを取得中…")
                        .tint(palette.accent)
                        .detailCardSecondaryText()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 4)

                case .loaded(let risk, let isFromCache):
                    HeatStrokeRiskBannerView(risk: risk)
                    if isFromCache {
                        Text("前回取得したWBGTデータを表示中")
                            .font(.caption)
                            .detailCardSecondaryText()
                    }

                case .failed:
                    Text("WBGT（暑さ指数）を取得できませんでした。表示できない＝安全という意味ではありません。通信環境を確認するか、環境省の熱中症予防情報サイトで最新の暑さ指数をご確認ください。")
                        .font(.caption)
                        .foregroundStyle(palette.warning)

                case .unavailable:
                    EmptyView()
                }
            }
        }
    }

    @ViewBuilder
    private func todayHourlyForecastContent(_ forecast: [HourlyWeatherForecast]) -> some View {
        if forecast.isEmpty == false {
            Divider()
                .padding(.vertical, 4)

            Text("1時間ごとの予報")
                .font(.subheadline)
                .detailCardSecondaryText()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(forecast.enumerated()), id: \.element.id) { index, slot in
                        HourlyForecastSlotView(
                            slot: slot,
                            isNow: index == 0
                        )
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }

    @ViewBuilder
    private func weeklyForecastContent(_ forecast: [DailyWeatherForecast]) -> some View {
        Divider()
            .padding(.vertical, 4)

        Text("1週間の予報")
            .font(.subheadline)
            .detailCardSecondaryText()

        ForEach(forecast) { day in
            HStack(spacing: 8) {
                Text(day.dateLabel)
                    .frame(width: 88, alignment: .leading)
                WeatherIconView(condition: day.condition, iconSize: 20)
                Text(day.condition)
                    .frame(maxWidth: .infinity, alignment: .leading)
                VStack(alignment: .trailing, spacing: 2) {
                    Text("\(day.minTemperatureCelsius)° / \(day.maxTemperatureCelsius)°")
                    Text("湿度 \(day.humidityPercent)%")
                        .font(.caption)
                }
                .detailCardSecondaryText()
            }
            .font(.subheadline)
        }
    }
}

private struct HourlyForecastSlotView: View {
    let slot: HourlyWeatherForecast
    let isNow: Bool

    @Environment(\.detailPalette) private var palette

    var body: some View {
        VStack(spacing: 6) {
            Text(isNow ? "今" : slot.timeLabel)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundStyle(isNow ? palette.accent : palette.secondaryText)

            WeatherIconView(condition: slot.condition, iconSize: 24)

            Text("\(slot.temperatureCelsius)°")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundStyle(palette.text)

            VStack(spacing: 4) {
                hourlyMetricRow(
                    icon: "humidity.fill",
                    value: "\(slot.humidityPercent)%",
                    color: palette.secondaryText
                )
                hourlyMetricRow(
                    icon: "drop.fill",
                    value: "\(slot.precipitationProbabilityPercent)%",
                    color: .blue.opacity(0.85)
                )
            }
        }
        .frame(width: 70)
        .padding(.vertical, 10)
        .padding(.horizontal, 4)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(isNow ? palette.accent.opacity(0.14) : palette.hourlySlotBackground)
        }
        .overlay {
            if isNow {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(palette.accent.opacity(0.85), lineWidth: 1.5)
            }
        }
    }

    // 湿度・降水確率は幅70pxのスロット内で常に同じ横並び（アイコン＋数値）にする
    private func hourlyMetricRow(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
            Text(value)
                .monospacedDigit()
        }
        .font(.caption2)
        .foregroundStyle(color)
        .lineLimit(1)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    WeatherSectionView(
        state: .loaded(
            WeatherInfo(
                temperatureCelsius: 28,
                condition: "晴れ",
                humidityPercent: 72,
                windSpeedKmh: 14,
                todayHourlyForecast: [
                    HourlyWeatherForecast(
                        id: "2026-06-21T09:00",
                        timeLabel: "9時",
                        temperatureCelsius: 27,
                        condition: "晴れ",
                        humidityPercent: 72,
                        precipitationProbabilityPercent: 10
                    ),
                    HourlyWeatherForecast(
                        id: "2026-06-21T10:00",
                        timeLabel: "10時",
                        temperatureCelsius: 28,
                        condition: "晴れ",
                        humidityPercent: 70,
                        precipitationProbabilityPercent: 5
                    ),
                    HourlyWeatherForecast(
                        id: "2026-06-21T11:00",
                        timeLabel: "11時",
                        temperatureCelsius: 29,
                        condition: "くもり",
                        humidityPercent: 68,
                        precipitationProbabilityPercent: 20
                    ),
                ],
                weeklyForecast: [
                    DailyWeatherForecast(
                        id: "2026-06-21",
                        dateLabel: "6/21（土）",
                        minTemperatureCelsius: 24,
                        maxTemperatureCelsius: 29,
                        condition: "晴れ",
                        humidityPercent: 72
                    ),
                ]
            ),
            isFromCache: false
        ),
        heatStrokeState: .loaded(
            HeatStrokeRiskInfo(currentWBGT: 26.0, todayMaxWBGT: 31.0),
            isFromCache: false
        )
    )
    .padding()
}

#Preview("WBGT取得失敗") {
    WeatherSectionView(
        state: .loaded(
            WeatherInfo(
                temperatureCelsius: 28,
                condition: "晴れ",
                humidityPercent: 72,
                windSpeedKmh: 14,
                todayHourlyForecast: [],
                weeklyForecast: []
            ),
            isFromCache: false
        ),
        heatStrokeState: .failed
    )
    .padding()
}
