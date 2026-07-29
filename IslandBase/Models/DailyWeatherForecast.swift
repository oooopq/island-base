//
//  DailyWeatherForecast.swift
//  Island Base
//
//  1日分の天気予報
//

import Foundation

struct DailyWeatherForecast: Codable, Identifiable {
    let id: String
    let dateLabel: String
    let minTemperatureCelsius: Int
    let maxTemperatureCelsius: Int
    let condition: String
    let weatherCode: Int?
    let humidityPercent: Int
    /// 1日の最大降水確率（%）
    let precipitationProbabilityPercent: Int

    func localizedCondition(language: AppLanguageMode) -> String {
        let code = WeatherConditionMapper.resolvedWeatherCode(storedCode: weatherCode, condition: condition)
        if let code {
            return WeatherConditionMapper.localizedCondition(for: code, language: language)
        }
        return condition
    }

    func localizedDateLabel(language: AppLanguageMode) -> String {
        WeatherLabelFormatter.dailyDateLabel(from: id, fallback: dateLabel, language: language)
    }
}
