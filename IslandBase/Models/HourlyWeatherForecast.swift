//
//  HourlyWeatherForecast.swift
//  Island Base
//
//  時間帯ごとの天気（1時間おき表示用）
//

import Foundation

struct HourlyWeatherForecast: Codable, Identifiable {
    let id: String
    let timeLabel: String
    let temperatureCelsius: Int
    let condition: String
    let humidityPercent: Int
    let precipitationProbabilityPercent: Int
    /// 予想降水量（mm）
    let precipitationMillimeters: Double
    /// 風速（km/h。表示時に m/s に変換する）
    let windSpeedKmh: Int
}
