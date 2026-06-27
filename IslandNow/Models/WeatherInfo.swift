//
//  WeatherInfo.swift
//  Island Now
//
//  1島分の天気情報（現在＋1週間予報）
//

import Foundation

struct WeatherInfo: Codable {
    let temperatureCelsius: Int
    let condition: String
    let humidityPercent: Int
    let windSpeedKmh: Int
    let todayHourlyForecast: [HourlyWeatherForecast]
    let weeklyForecast: [DailyWeatherForecast]
}
