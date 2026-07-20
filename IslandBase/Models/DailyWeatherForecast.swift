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
    let humidityPercent: Int
    /// 1日の最大降水確率（%）
    let precipitationProbabilityPercent: Int
}
