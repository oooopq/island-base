//
//  WeatherIconMapper.swift
//  Island Base
//
//  天候テキストから SF Symbols のアイコン名を返す
//

import SwiftUI

enum WeatherIconMapper {
    static func systemImage(for condition: String) -> String {
        switch condition {
        case "晴れ":
            return "sun.max.fill"
        case "くもり":
            return "cloud.fill"
        case "霧":
            return "cloud.fog.fill"
        case "小雨":
            return "cloud.drizzle.fill"
        case "雨":
            return "cloud.rain.fill"
        case "雪":
            return "cloud.snow.fill"
        case "にわか雨":
            return "cloud.heavyrain.fill"
        case "雷雨":
            return "cloud.bolt.rain.fill"
        default:
            return "questionmark.circle.fill"
        }
    }

    static func color(for condition: String) -> Color {
        switch condition {
        case "晴れ":
            return .orange
        case "くもり", "霧":
            return .gray
        case "小雨", "雨", "にわか雨":
            return .blue
        case "雪":
            return .cyan
        case "雷雨":
            return .purple
        default:
            return .secondary
        }
    }
}
