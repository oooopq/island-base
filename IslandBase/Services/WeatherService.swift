//
//  WeatherService.swift
//  Island Base
//
//  GitHub Pages 上の天気キャッシュ JSON を取得する（出典: Open-Meteo）
//

import Foundation

struct WeatherService {
    // v6: Pages キャッシュ取得に切り替え（v5 は UserDefaults に残るが読み込まない）
    private let cacheKeyPrefix = "weather_cache_v6_"

    // 圏外時に長く待たない（waitsForConnectivity = false）
    private static let pagesSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = NetworkTimeout.weatherPagesSeconds
        config.timeoutIntervalForResource = NetworkTimeout.weatherPagesSeconds + 2
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }()

    // GitHub Pages から島ごとの天気 JSON を取得し、端末にも保存する
    func fetchWeather(for island: Island) async throws -> WeatherInfo {
        let weather = try await fetchFromPagesCache(islandID: island.id)
        saveCache(weather, for: island.id)
        return weather
    }

    // オフライン用：最後に取得した天気を読み出す
    func cachedWeather(for islandID: String) -> WeatherInfo? {
        let key = cacheKeyPrefix + islandID
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        if let weather = try? JSONDecoder().decode(WeatherInfo.self, from: data) {
            return weather
        }

        UserDefaults.standard.removeObject(forKey: key)
        return nil
    }

    private func saveCache(_ weather: WeatherInfo, for islandID: String) {
        guard let data = try? JSONEncoder().encode(weather) else { return }
        UserDefaults.standard.set(data, forKey: cacheKeyPrefix + islandID)
    }

    private func fetchFromPagesCache(islandID: String) async throws -> WeatherInfo {
        guard NetworkConnectivity.isConnected else {
            throw WeatherServiceError.networkUnavailable
        }

        let url = try makeCacheURL(for: islandID)
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = NetworkTimeout.weatherPagesSeconds

        let (data, response) = try await Self.pagesSession.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherServiceError.badResponse
        }

        let payload = try JSONDecoder().decode(WeatherCachePayload.self, from: data)
        guard let weather = payload.toWeatherInfo() else {
            throw WeatherServiceError.badResponse
        }
        return weather
    }

    private func makeCacheURL(for islandID: String) throws -> URL {
        let hourBlock = Self.jstHourBlockString()
        let urlString = "\(AppLegalInfo.weatherCacheBaseURL)/\(islandID).json?h=\(hourBlock)"
        guard let url = URL(string: urlString) else {
            throw WeatherServiceError.invalidURL
        }
        return url
    }

    /// CDN キャッシュ対策: JST の時間ブロック（YYYYMMDDHH）
    private static func jstHourBlockString(for date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour else {
            return "0000000000"
        }
        return String(format: "%04d%02d%02d%02d", year, month, day, hour)
    }
}

enum WeatherServiceError: Error {
    case invalidURL
    case badResponse
    case networkUnavailable
}

// GitHub Pages 配信 JSON（WeatherInfo 互換 + updatedAt）
private struct WeatherCachePayload: Decodable {
    let updatedAt: String
    let temperatureCelsius: Int
    let apparentTemperatureCelsius: Int?
    let condition: String
    let humidityPercent: Int
    let windSpeedKmh: Int
    let currentWaveHeightMeters: Double?
    let todayMaxWaveHeightMeters: Double?
    let todayHourlyForecast: [HourlyWeatherForecast]
    let weeklyForecast: [DailyWeatherForecast]

    func toWeatherInfo() -> WeatherInfo? {
        guard let fetchedAt = Self.parseUpdatedAt(updatedAt) else {
            return nil
        }

        return WeatherInfo(
            temperatureCelsius: temperatureCelsius,
            apparentTemperatureCelsius: apparentTemperatureCelsius,
            condition: condition,
            humidityPercent: humidityPercent,
            windSpeedKmh: windSpeedKmh,
            currentWaveHeightMeters: currentWaveHeightMeters,
            todayMaxWaveHeightMeters: todayMaxWaveHeightMeters,
            todayHourlyForecast: todayHourlyForecast,
            weeklyForecast: weeklyForecast,
            fetchedAt: fetchedAt
        )
    }

    private static func parseUpdatedAt(_ text: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: text) {
            return date
        }

        // フォールバック（秒なしなど）
        formatter.formatOptions = [.withFullDate, .withTime, .withColonSeparatorInTime, .withTimeZone]
        return formatter.date(from: text)
    }
}
