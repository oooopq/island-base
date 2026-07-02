//
//  WeatherSectionView.swift
//  Island Now
//
//  詳細画面の天気セクション（現在＋1週間予報）
//

import SwiftUI

struct WeatherSectionView: View {
    let state: WeatherLoadState

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
                    todayHourlyForecastContent(cachedWeather.todayHourlyForecast)
                    weeklyForecastContent(cachedWeather.weeklyForecast)
                    Text("オフライン用の保存データです")
                        .font(.caption)
                        .detailCardSecondaryText()
                }
            }

            openMeteoAttribution
        }
        .detailSectionCard()
    }

    // CC BY 4.0：天気データ表示箇所の近くに Open-Meteo へのリンクを置く
    @ViewBuilder
    private var openMeteoAttribution: some View {
        if let url = AppURL.from(string: AppLegalInfo.openMeteoAttributionURL) {
            OpenURLButton(url: url) {
                Text(AppLegalInfo.openMeteoAttributionText)
                    .font(.caption2)
                    .foregroundStyle(palette.secondaryText)
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.top, 4)
        }
    }

    @ViewBuilder
    private func currentWeatherContent(_ weather: WeatherInfo) -> some View {
        Text("現在")
            .font(.subheadline)
            .detailCardSecondaryText()

        HStack(alignment: .top, spacing: 12) {
            HStack(alignment: .center, spacing: 16) {
                WeatherIconView(condition: weather.condition, iconSize: 56)

                VStack(alignment: .leading, spacing: 4) {
                    Text("\(weather.temperatureCelsius)°\u{2060}C")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text(weather.condition)
                        .font(.title3)
                }
            }
            .layoutPriority(1)

            Spacer(minLength: 8)

            currentWaveHeightPanel(weather)
        }

        HStack(alignment: .top, spacing: 12) {
            currentMetricPanel(
                icon: "humidity",
                title: "湿度",
                value: "\(weather.humidityPercent)%"
            )
            currentMetricPanel(
                icon: "wind",
                title: "風速",
                value: "\(formattedWindSpeedMs(kmh: weather.windSpeedKmh)) m/s"
            )
        }
    }

    @ViewBuilder
    private func currentMetricPanel(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(palette.secondaryText)

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(palette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
        .frame(maxWidth: .infinity, minHeight: 72, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.hourlySlotBackground)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
    }

    // 現在の天気の右側に波の高さを表示する
    @ViewBuilder
    private func currentWaveHeightPanel(_ weather: WeatherInfo) -> some View {
        VStack(alignment: .trailing, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "water.waves")
                    .font(.title3)
                Text("波の高さ")
                    .font(.subheadline.weight(.semibold))
            }
            .foregroundStyle(Color.cyan.opacity(0.9))

            if let current = weather.currentWaveHeightMeters {
                Text("\(formattedWaveHeight(current)) m")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(palette.text)

                if let maxHeight = weather.todayMaxWaveHeightMeters {
                    Text("最大 \(formattedWaveHeight(maxHeight)) m")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(palette.secondaryText)
                }

                Text("有義波高")
                    .font(.system(size: 11))
                    .foregroundStyle(palette.secondaryText)
            } else {
                Text("—")
                    .font(.system(size: 32, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.secondaryText)

                Text("取得できません")
                    .font(.system(size: 11))
                    .foregroundStyle(palette.warning)
            }
        }
        .fixedSize()
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.cyan.opacity(0.1))
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.cyan.opacity(0.25), lineWidth: 1)
        }
    }

    // km/h を m/s に変換して表示用に整形する（小数点1桁）
    private func formattedWindSpeedMs(kmh: Int) -> String {
        let metersPerSecond = Double(kmh) / 3.6
        return String(format: "%.1f", metersPerSecond)
    }

    private func formattedWaveHeight(_ meters: Double) -> String {
        String(format: "%.1f", meters)
    }

    @ViewBuilder
    private func todayHourlyForecastContent(_ forecast: [HourlyWeatherForecast]) -> some View {
        if forecast.isEmpty == false {
            Divider()
                .padding(.vertical, 4)

            Text("1時間ごとの予報")
                .font(.subheadline)
                .detailCardSecondaryText()

            HourlyForecastPanelView(forecast: forecast)
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
                    Label("降水 \(day.precipitationProbabilityPercent)%", systemImage: "drop.fill")
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
                currentWaveHeightMeters: 1.1,
                todayMaxWaveHeightMeters: 1.4,
                todayHourlyForecast: [
                    HourlyWeatherForecast(
                        id: "2026-06-21T09:00",
                        timeLabel: "9時",
                        temperatureCelsius: 27,
                        condition: "晴れ",
                        humidityPercent: 72,
                        precipitationProbabilityPercent: 10,
                        precipitationMillimeters: 0,
                        windSpeedKmh: 14
                    ),
                ],
                weeklyForecast: [
                    DailyWeatherForecast(
                        id: "2026-06-21",
                        dateLabel: "6/21（土）",
                        minTemperatureCelsius: 24,
                        maxTemperatureCelsius: 29,
                        condition: "晴れ",
                        humidityPercent: 72,
                        precipitationProbabilityPercent: 20
                    ),
                ]
            ),
            isFromCache: false
        )
    )
    .padding()
}
