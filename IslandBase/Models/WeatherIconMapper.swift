//
//  WeatherIconMapper.swift
//  Island Base
//
//  天候コード・テキストから SF Symbols のアイコン名を返す
//

import SwiftUI

enum WeatherIconMapper {
    static func systemImage(weatherCode: Int?, condition: String) -> String {
        if let code = WeatherConditionMapper.resolvedWeatherCode(storedCode: weatherCode, condition: condition) {
            return systemImage(forWeatherCode: code)
        }
        return systemImage(for: condition)
    }

    static func color(weatherCode: Int?, condition: String) -> Color {
        if let code = WeatherConditionMapper.resolvedWeatherCode(storedCode: weatherCode, condition: condition) {
            return color(forWeatherCode: code)
        }
        return color(for: condition)
    }

    static func systemImage(forWeatherCode code: Int) -> String {
        switch code {
        case 0:
            return "sun.max.fill"
        case 1, 2, 3:
            return "cloud.fill"
        case 45, 48:
            return "cloud.fog.fill"
        case 51, 53, 55:
            return "cloud.drizzle.fill"
        case 61, 63, 65:
            return "cloud.rain.fill"
        case 71, 73, 75:
            return "cloud.snow.fill"
        case 80, 81, 82:
            return "cloud.heavyrain.fill"
        case 95, 96, 99:
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    static func color(forWeatherCode code: Int) -> Color {
        switch code {
        case 0:
            return .orange
        case 1, 2, 3, 45, 48:
            return .gray
        case 51, 53, 55, 61, 63, 65, 80, 81, 82:
            return .blue
        case 71, 73, 75:
            return .cyan
        case 95, 96, 99:
            return .purple
        default:
            return .secondary
        }
    }

    static func systemImage(for condition: String) -> String {
        switch condition {
        case "晴れ", "Clear":
            return "sun.max.fill"
        case "くもり", "Cloudy":
            return "cloud.fill"
        case "霧", "Fog":
            return "cloud.fog.fill"
        case "小雨", "Drizzle":
            return "cloud.drizzle.fill"
        case "雨", "Rain":
            return "cloud.rain.fill"
        case "雪", "Snow":
            return "cloud.snow.fill"
        case "にわか雨", "Showers":
            return "cloud.heavyrain.fill"
        case "雷雨", "Thunderstorm":
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    static func color(for condition: String) -> Color {
        switch condition {
        case "晴れ", "Clear":
            return .orange
        case "くもり", "Cloudy", "霧", "Fog":
            return .gray
        case "小雨", "Drizzle", "雨", "Rain", "にわか雨", "Showers":
            return .blue
        case "雪", "Snow":
            return .cyan
        case "雷雨", "Thunderstorm":
            return .purple
        default:
            return .secondary
        }
    }
}
