//
//  HourlyForecastPanelView.swift
//  Island Base
//
//  1時間ごとの予報（気温の折れ線グラフ＋コンパクトな時間スロット）
//

import SwiftUI

struct HourlyForecastPanelView: View {
    let forecast: [HourlyWeatherForecast]

    private let slotWidth: CGFloat = 50
    private let slotSpacing: CGFloat = 4

    private var panelWidth: CGFloat {
        let count = CGFloat(forecast.count)
        guard count > 0 else { return 0 }
        return count * slotWidth + max(0, count - 1) * slotSpacing
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 6) {
                HourlyTemperatureLineChart(
                    temperatures: forecast.map(\.temperatureCelsius),
                    slotWidth: slotWidth,
                    slotSpacing: slotSpacing
                )
                .frame(width: panelWidth, height: 56)

                HStack(spacing: slotSpacing) {
                    ForEach(Array(forecast.enumerated()), id: \.element.id) { index, slot in
                        HourlyForecastCompactSlotView(
                            slot: slot,
                            isNow: index == 0
                        )
                        .frame(width: slotWidth)
                    }
                }
            }
            .padding(.vertical, 2)
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("1時間ごとの気温グラフと予報")
    }
}

// 気温帯ごとのグラフ色
private enum TemperatureChartColor {
    static func color(for celsius: Int) -> Color {
        switch celsius {
        case 35...:
            return Color(red: 0.45, green: 0.02, blue: 0.02)
        case 30..<35:
            return .red
        case 20..<30:
            return .orange
        case 11..<20:
            return Color(red: 0.92, green: 0.78, blue: 0.05)
        default:
            return .blue
        }
    }
}

// 時間軸に沿った気温の折れ線グラフ（区間ごとに色が変わる）
private struct HourlyTemperatureLineChart: View {
    let temperatures: [Int]
    let slotWidth: CGFloat
    let slotSpacing: CGFloat

    var body: some View {
        Canvas { context, size in
            guard temperatures.count >= 2 else { return }

            let minTemp = Double(temperatures.min() ?? 0) - 1
            let maxTemp = Double(temperatures.max() ?? 0) + 1
            let range = max(maxTemp - minTemp, 1)
            let step = slotWidth + slotSpacing
            let chartHeight = size.height - 6

            let points = temperatures.enumerated().map { index, temp -> CGPoint in
                let x = CGFloat(index) * step + slotWidth / 2
                let normalized = (Double(temp) - minTemp) / range
                let y = size.height - CGFloat(normalized) * chartHeight - 3
                return CGPoint(x: x, y: y)
            }

            // 区間ごとに塗りつぶし
            for index in 0..<(points.count - 1) {
                let segmentColor = TemperatureChartColor.color(for: temperatures[index])
                var fillPath = Path()
                fillPath.move(to: CGPoint(x: points[index].x, y: size.height))
                fillPath.addLine(to: points[index])
                fillPath.addLine(to: points[index + 1])
                fillPath.addLine(to: CGPoint(x: points[index + 1].x, y: size.height))
                fillPath.closeSubpath()
                context.fill(fillPath, with: .color(segmentColor.opacity(0.15)))
            }

            // 区間ごとに折れ線
            for index in 0..<(points.count - 1) {
                let segmentColor = TemperatureChartColor.color(for: temperatures[index])
                var linePath = Path()
                linePath.move(to: points[index])
                linePath.addLine(to: points[index + 1])
                context.stroke(
                    linePath,
                    with: .color(segmentColor),
                    style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
                )
            }

            // 各時間の点（気温帯の色）
            for (index, point) in points.enumerated() {
                let isNow = index == 0
                let radius: CGFloat = isNow ? 4 : 2.5
                let dotColor = TemperatureChartColor.color(for: temperatures[index])
                let dotRect = CGRect(
                    x: point.x - radius,
                    y: point.y - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                context.fill(Circle().path(in: dotRect), with: .color(dotColor))
            }
        }
    }
}

private struct HourlyForecastCompactSlotView: View {
    let slot: HourlyWeatherForecast
    let isNow: Bool

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(spacing: 2) {
            Text(isNow ? "今" : slot.timeLabel)
                .font(.system(size: 10, weight: .semibold))
                .foregroundStyle(isNow ? palette.accent : palette.secondaryText)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            WeatherIconView(condition: slot.condition, iconSize: 14)

            Text("\(slot.temperatureCelsius)°")
                .font(.system(size: 11, weight: .semibold))
                .monospacedDigit()
                .foregroundStyle(palette.text)

            if let apparentCelsius = slot.displayApparentTemperatureCelsius {
                Text(languageStore.t(.feelsLikeTemperature(apparentCelsius)))
                    .font(.system(size: 8, weight: .medium))
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            VStack(spacing: 1) {
                compactMetric(icon: "humidity.fill", value: "\(slot.humidityPercent)%")
                compactMetric(icon: "wind", value: formattedWindSpeedMs(kmh: slot.windSpeedKmh))
                compactMetric(icon: "cloud.rain.fill", value: formattedPrecipitation(slot.precipitationMillimeters))
            }
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 2)
        .background {
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(isNow ? palette.accent.opacity(0.12) : palette.hourlySlotBackground)
        }
        .overlay {
            if isNow {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(palette.accent.opacity(0.75), lineWidth: 1)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    private var accessibilityText: String {
        let time = isNow ? "現在" : slot.timeLabel
        var text = "\(time) \(slot.condition) 気温\(slot.temperatureCelsius)度"
        if let apparentCelsius = slot.displayApparentTemperatureCelsius {
            text += " 体感\(apparentCelsius)度"
        }
        text += " 湿度\(slot.humidityPercent)パーセント 風速\(formattedWindSpeedMs(kmh: slot.windSpeedKmh))メートル毎秒 降水量\(formattedPrecipitation(slot.precipitationMillimeters))"
        return text
    }

    private func compactMetric(icon: String, value: String) -> some View {
        HStack(spacing: 2) {
            Image(systemName: icon)
            Text(value)
                .monospacedDigit()
        }
        .font(.system(size: 9))
        .foregroundStyle(palette.secondaryText)
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }

    private func formattedWindSpeedMs(kmh: Int) -> String {
        let metersPerSecond = Double(kmh) / 3.6
        return String(format: "%.1fm/s", metersPerSecond)
    }

    private func formattedPrecipitation(_ millimeters: Double) -> String {
        if millimeters < 0.05 {
            return "0mm"
        }
        return String(format: "%.1fmm", millimeters)
    }
}

#Preview {
    HourlyForecastPanelView(
        forecast: (9...20).map { hour in
            HourlyWeatherForecast(
                id: "2026-06-21T\(hour):00",
                timeLabel: "\(hour)時",
                temperatureCelsius: 8 + hour,
                apparentTemperatureCelsius: hour % 2 == 0 ? 8 + hour + 3 : nil,
                condition: hour % 3 == 0 ? "くもり" : "晴れ",
                humidityPercent: 70 - hour,
                precipitationProbabilityPercent: hour % 4 == 0 ? 30 : 5,
                precipitationMillimeters: hour % 4 == 0 ? 1.2 : 0,
                windSpeedKmh: 10 + hour
            )
        }
    )
    .padding()
    .environment(\.detailPalette, DetailCardPalette.dark)
}
