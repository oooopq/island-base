//
//  WeatherInfo.swift
//  Island Base
//
//  1島分の天気情報（現在＋1週間予報）
//

import Foundation

struct WeatherInfo: Codable {
    let temperatureCelsius: Int
    /// Open-Meteo の体感温度（実温とほぼ同じときは表示しない）
    let apparentTemperatureCelsius: Int?
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

    /// 実温との差がこの値以下なら体感温度行を出さない
    static let apparentTemperatureDisplayThresholdCelsius = 1

    /// 画面表示用の体感温度（nil なら行を出さない）
    var displayApparentTemperatureCelsius: Int? {
        guard let apparentTemperatureCelsius else { return nil }
        guard abs(apparentTemperatureCelsius - temperatureCelsius) > Self.apparentTemperatureDisplayThresholdCelsius else {
            return nil
        }
        return apparentTemperatureCelsius
    }

    init(
        temperatureCelsius: Int,
        apparentTemperatureCelsius: Int? = nil,
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
        self.apparentTemperatureCelsius = apparentTemperatureCelsius
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
