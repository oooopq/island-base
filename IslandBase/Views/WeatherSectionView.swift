//
//  WeatherSectionView.swift
//  Island Base
//
//  詳細画面の天気セクション（現在＋週間天気）
//

import SwiftUI

struct WeatherSectionView: View {
    let state: WeatherLoadState

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
    @State private var isWeeklyForecastExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(languageStore.t(.weather))
                .font(.headline)

            switch state {
            case .loading:
                ProgressView(languageStore.t(.loadingWeather))
                    .tint(palette.accent)
                    .detailCardSecondaryText()

            case .loaded(let weather, let isFromCache):
                currentWeatherContent(weather)
                todayHourlyForecastContent(weather.todayHourlyForecast)
                weeklyForecastContent(weather.weeklyForecast)
                if let cacheText = CacheAgeText.displayText(
                    fetchedAt: weather.fetchedAt,
                    isFromCache: isFromCache,
                    language: languageStore.mode
                ) {
                    Text(cacheText)
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
                    if let cacheText = CacheAgeText.displayText(
                        fetchedAt: cachedWeather.fetchedAt,
                        isFromCache: true,
                        language: languageStore.mode
                    ) {
                        Text(cacheText)
                            .font(.caption)
                            .detailCardSecondaryText()
                    }
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
        Text(languageStore.t(.current))
            .font(.subheadline)
            .detailCardSecondaryText()

        VStack(spacing: 10) {
            HStack(alignment: .top, spacing: 8) {
                // 気温は残り幅、波パネルは固定幅で潰さない
                currentWeatherPrimaryBlock(weather)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)

                currentWaveHeightPanel(weather)
            }

            HStack(spacing: 10) {
                currentWeatherSecondaryMetric(
                    icon: "humidity",
                    label: languageStore.t(.humidity),
                    value: "\(weather.humidityPercent)%"
                )

                currentWeatherSecondaryMetric(
                    icon: "wind",
                    label: languageStore.t(.windSpeed),
                    value: "\(formattedWindSpeedMs(kmh: weather.windSpeedKmh)) m/s"
                )
            }
        }
    }

    // 気温ブロック（狭い幅では文字を少し小さくして収める）
    @ViewBuilder
    private func currentWeatherPrimaryBlock(_ weather: WeatherInfo) -> some View {
        HStack(alignment: .center, spacing: 10) {
            WeatherIconView(condition: weather.condition, iconSize: 52)

            VStack(alignment: .leading, spacing: 2) {
                Text("\(weather.temperatureCelsius)°\u{2060}C")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.55)

                if let apparentCelsius = weather.displayApparentTemperatureCelsius {
                    Text(languageStore.t(.feelsLikeTemperature(apparentCelsius)))
                        .font(.caption.weight(.medium))
                        .detailCardSecondaryText()
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }

                Text(weather.condition)
                    .font(.subheadline.weight(.medium))
                    .detailCardSecondaryText()
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            .frame(minWidth: 0, alignment: .leading)
        }
    }

    // 湿度・風速を同じサイズの下段タイルとして表示する
    @ViewBuilder
    private func currentWeatherSecondaryMetric(icon: String, label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon)
                .font(.caption.weight(.semibold))
                .detailCardSecondaryText()
                .labelStyle(.titleAndIcon)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .monospacedDigit()
                .foregroundStyle(palette.text)
                .lineLimit(1)
                .minimumScaleFactor(0.85)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.chipBackground(isSelected: false))
        }
    }

    // 波の高さ（幅を固定して英語でも気温側を押しつぶさない／消えない）
    @ViewBuilder
    private func currentWaveHeightPanel(_ weather: WeatherInfo) -> some View {
        VStack(alignment: .trailing, spacing: 4) {
            Label(languageStore.t(.waveHeight), systemImage: "water.waves")
                .font(.caption.weight(.semibold))
                .labelStyle(.titleAndIcon)
                .foregroundStyle(Color.cyan.opacity(0.9))
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            if let current = weather.currentWaveHeightMeters {
                Text("\(formattedWaveHeight(current)) m")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(palette.text)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                if let maxHeight = weather.todayMaxWaveHeightMeters {
                    Text(languageStore.t(.waveMax(formattedWaveHeight(maxHeight))))
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(palette.secondaryText)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }

                Text(languageStore.t(.significantWaveHeight))
                    .font(.system(size: 10))
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.65)
                    .multilineTextAlignment(.trailing)
            } else {
                Text("—")
                    .font(.system(size: 24, weight: .semibold, design: .rounded))
                    .foregroundStyle(palette.secondaryText)

                Text(languageStore.t(.waveUnavailable))
                    .font(.system(size: 10))
                    .foregroundStyle(palette.warning)
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.trailing)
            }
        }
        .frame(width: 112, alignment: .trailing)
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
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

            Text(languageStore.t(.hourlyForecast))
                .font(.subheadline)
                .detailCardSecondaryText()

            HourlyForecastPanelView(forecast: forecast)
        }
    }

    @ViewBuilder
    private func weeklyForecastContent(_ forecast: [DailyWeatherForecast]) -> some View {
        if forecast.isEmpty == false {
            Divider()
                .padding(.vertical, 4)

            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isWeeklyForecastExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    Text(languageStore.t(.weeklyWeather))
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer(minLength: 0)

                    Image(systemName: isWeeklyForecastExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption.weight(.semibold))
                }
                .foregroundStyle(palette.text)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("週間天気")
            .accessibilityHint(isWeeklyForecastExpanded ? "タップで閉じる" : "タップで週間天気を表示")

            if isWeeklyForecastExpanded {
                WeeklyForecastPanelView(forecast: forecast)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

#Preview {
    WeatherSectionView(
        state: .loaded(
            WeatherInfo(
                temperatureCelsius: 28,
                apparentTemperatureCelsius: 35,
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
                        apparentTemperatureCelsius: 31,
                        condition: "晴れ",
                        humidityPercent: 72,
                        precipitationProbabilityPercent: 10,
                        precipitationMillimeters: 0,
                        windSpeedKmh: 14
                    ),
                ],
                weeklyForecast: (21...27).map { day in
                    DailyWeatherForecast(
                        id: "2026-06-\(day)",
                        dateLabel: "6/\(day)（\(["土", "日", "月", "火", "水", "木", "金"][day - 21])）",
                        minTemperatureCelsius: 24,
                        maxTemperatureCelsius: 29,
                        condition: "晴れ",
                        humidityPercent: 72,
                        precipitationProbabilityPercent: 20
                    )
                }
            ),
            isFromCache: false
        )
    )
    .padding()
}
