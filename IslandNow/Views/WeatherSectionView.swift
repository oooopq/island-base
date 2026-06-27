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

            case .loaded(let weather, let isFromCache):
                currentWeatherContent(weather)
                heatStrokeRiskContent
                todayThreeHourForecastContent(weather.todayThreeHourForecast)
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
                    todayThreeHourForecastContent(cachedWeather.todayThreeHourForecast)
                    weeklyForecastContent(cachedWeather.weeklyForecast)
                    Text("オフライン用の保存データです")
                        .font(.caption)
                        .detailCardSecondaryText()
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

        Label("風速 \(weather.windSpeedKmh) km/h", systemImage: "wind")
            .font(.subheadline)
            .detailCardSecondaryText()
    }

    @ViewBuilder
    private var heatStrokeRiskContent: some View {
        switch heatStrokeState {
        case .unavailable:
            EmptyView()
        case .loading:
            ProgressView()
                .tint(palette.accent)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
        case .loaded(let risk, _):
            HeatStrokeRiskBannerView(risk: risk)
        case .failed:
            EmptyView()
        }
    }

    @ViewBuilder
    private func todayThreeHourForecastContent(_ forecast: [HourlyWeatherForecast]) -> some View {
        if forecast.isEmpty == false {
            Divider()
                .padding(.vertical, 4)

            Text("今日の天気（3時間おき）")
                .font(.subheadline)
                .detailCardSecondaryText()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(forecast) { slot in
                        VStack(spacing: 6) {
                            Text(slot.timeLabel)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(palette.accent)

                            WeatherIconView(condition: slot.condition, iconSize: 28)

                            Text("\(slot.temperatureCelsius)°")
                                .font(.subheadline)
                                .fontWeight(.medium)

                            Text(slot.condition)
                                .font(.caption2)
                                .detailCardSecondaryText()
                                .lineLimit(1)

                            Text("湿度 \(slot.humidityPercent)%")
                                .font(.caption2)
                                .detailCardSecondaryText()

                            Label("\(slot.precipitationProbabilityPercent)%", systemImage: "drop.fill")
                                .font(.caption2)
                                .foregroundStyle(.blue.opacity(0.85))
                        }
                        .frame(width: 72)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .background {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(palette.hourlySlotBackground)
                        }
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

#Preview {
    WeatherSectionView(
        state: .loaded(
            WeatherInfo(
                temperatureCelsius: 28,
                condition: "晴れ",
                humidityPercent: 72,
                windSpeedKmh: 14,
                todayThreeHourForecast: [
                    HourlyWeatherForecast(
                        id: "2026-06-21T09:00",
                        timeLabel: "9時",
                        temperatureCelsius: 27,
                        condition: "晴れ",
                        humidityPercent: 72,
                        precipitationProbabilityPercent: 10
                    ),
                    HourlyWeatherForecast(
                        id: "2026-06-21T12:00",
                        timeLabel: "12時",
                        temperatureCelsius: 29,
                        condition: "くもり",
                        humidityPercent: 68,
                        precipitationProbabilityPercent: 30
                    ),
                    HourlyWeatherForecast(
                        id: "2026-06-21T21:00",
                        timeLabel: "21時",
                        temperatureCelsius: 24,
                        condition: "くもり",
                        humidityPercent: 85,
                        precipitationProbabilityPercent: 0
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
