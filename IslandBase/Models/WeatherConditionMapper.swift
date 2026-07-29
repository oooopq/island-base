//
//  WeatherConditionMapper.swift
//  Island Base
//
//  WMO 天気コードを画面表示用の文言に変換する（fetch_weather_cache.py と同一）
//

import Foundation

enum WeatherConditionMapper {
    static func localizedCondition(for code: Int, language: AppLanguageMode) -> String {
        language.isJapanese ? japaneseCondition(for: code) : englishCondition(for: code)
    }

    static func japaneseCondition(for code: Int) -> String {
        switch code {
        case 0:
            return "晴れ"
        case 1, 2, 3:
            return "くもり"
        case 45, 48:
            return "霧"
        case 51, 53, 55:
            return "小雨"
        case 61, 63, 65:
            return "雨"
        case 71, 73, 75:
            return "雪"
        case 80, 81, 82:
            return "にわか雨"
        case 95, 96, 99:
            return "雷雨"
        default:
            return "不明"
        }
    }

    static func englishCondition(for code: Int) -> String {
        switch code {
        case 0:
            return "Clear"
        case 1, 2, 3:
            return "Cloudy"
        case 45, 48:
            return "Fog"
        case 51, 53, 55:
            return "Drizzle"
        case 61, 63, 65:
            return "Rain"
        case 71, 73, 75:
            return "Snow"
        case 80, 81, 82:
            return "Showers"
        case 95, 96, 99:
            return "Thunderstorm"
        default:
            return "Unknown"
        }
    }

    /// 古いキャッシュ（weatherCode なし）向け：日本語 condition からコードを推定
    static func weatherCode(fromJapaneseCondition condition: String) -> Int? {
        switch condition {
        case "晴れ":
            return 0
        case "くもり":
            return 3
        case "霧":
            return 45
        case "小雨":
            return 51
        case "雨":
            return 61
        case "雪":
            return 71
        case "にわか雨":
            return 80
        case "雷雨":
            return 95
        default:
            return nil
        }
    }

    static func resolvedWeatherCode(storedCode: Int?, condition: String) -> Int? {
        if let storedCode {
            return storedCode
        }
        return weatherCode(fromJapaneseCondition: condition)
    }
}
