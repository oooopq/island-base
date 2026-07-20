//
//  WeatherInfo.swift
//  Island Base
//
//  1島分の天気情報（現在＋1週間予報）
//

import Foundation

struct WeatherInfo: Codable {
    let temperatureCelsius: Int
    let condition: String
    let humidityPercent: Int
    let windSpeedKmh: Int
    /// 現在の有義波高（メートル）。取得できない場合は nil
    let currentWaveHeightMeters: Double?
    /// 今日の最大有義波高（メートル）。取得できない場合は nil
    let todayMaxWaveHeightMeters: Double?
    let todayHourlyForecast: [HourlyWeatherForecast]
    let weeklyForecast: [DailyWeatherForecast]
    /// 端末に保存した取得時刻（古いキャッシュには無い）
    let fetchedAt: Date?

    init(
        temperatureCelsius: Int,
        condition: String,
        humidityPercent: Int,
        windSpeedKmh: Int,
        currentWaveHeightMeters: Double?,
        todayMaxWaveHeightMeters: Double?,
        todayHourlyForecast: [HourlyWeatherForecast],
        weeklyForecast: [DailyWeatherForecast],
        fetchedAt: Date? = nil
    ) {
        self.temperatureCelsius = temperatureCelsius
        self.condition = condition
        self.humidityPercent = humidityPercent
        self.windSpeedKmh = windSpeedKmh
        self.currentWaveHeightMeters = currentWaveHeightMeters
        self.todayMaxWaveHeightMeters = todayMaxWaveHeightMeters
        self.todayHourlyForecast = todayHourlyForecast
        self.weeklyForecast = weeklyForecast
        self.fetchedAt = fetchedAt
    }
}
