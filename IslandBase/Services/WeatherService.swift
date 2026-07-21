//
//  WeatherService.swift
//  Island Base
//
//  Open-Meteo（無料・APIキー不要）から天気と波の高さを取得する
//

import Foundation

struct WeatherService {
    // クエリ変更時に古い中心座標キャッシュを捨てる
    private let cacheKeyPrefix = "weather_cache_v5_"

    private static let forecastModels = "jma_seamless"
    private static let forecastElevationMeters = IslandWeatherLocation.defaultPortElevationMeters

    // 島の天気地点から天気（現在＋1時間おき24件＋1週間）と波の高さを取得し、キャッシュにも保存する
    func fetchWeather(for island: Island) async throws -> WeatherInfo {
        let query = weatherQuery(for: island)
        async let forecastData = fetchForecast(query: query)
        async let waveData = fetchWaveHeight(latitude: query.latitude, longitude: query.longitude)

        let decoded = try await forecastData
        let wave = await waveData
        let weather = decoded.toWeatherInfo(waveHeight: wave)
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

        // 古い形式のキャッシュは削除して再取得させる
        UserDefaults.standard.removeObject(forKey: key)
        return nil
    }

    private func saveCache(_ weather: WeatherInfo, for islandID: String) {
        guard let data = try? JSONEncoder().encode(weather) else { return }
        UserDefaults.standard.set(data, forKey: cacheKeyPrefix + islandID)
    }

    private func weatherQuery(for island: Island) -> WeatherQuery {
        if let location = IslandCatalog.profile(for: island)?.resolvedWeatherLocation {
            return WeatherQuery(
                latitude: location.latitude,
                longitude: location.longitude
            )
        }

        // プロファイルがない場合のみ島中心にフォールバック
        return WeatherQuery(
            latitude: island.latitude,
            longitude: island.longitude
        )
    }

    private func fetchForecast(query: WeatherQuery) async throws -> OpenMeteoResponse {
        let url = try makeForecastURL(query: query)
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw WeatherServiceError.badResponse
        }

        return try JSONDecoder().decode(OpenMeteoResponse.self, from: data)
    }

    // 波の高さは marine API から取得する（失敗しても天気表示は続行する）
    private func fetchWaveHeight(latitude: Double, longitude: Double) async -> WaveHeightData? {
        do {
            let url = try makeMarineURL(latitude: latitude, longitude: longitude)
            let (data, response) = try await URLSession.shared.data(from: url)

            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                return nil
            }

            let decoded = try JSONDecoder().decode(OpenMeteoMarineResponse.self, from: data)
            return decoded.toWaveHeightData()
        } catch {
            return nil
        }
    }

    private func makeForecastURL(query: WeatherQuery) throws -> URL {
        var components = URLComponents(string: "https://api.open-meteo.com/v1/forecast")
        var items: [URLQueryItem] = [
            URLQueryItem(name: "latitude", value: String(query.latitude)),
            URLQueryItem(name: "longitude", value: String(query.longitude)),
            URLQueryItem(name: "current", value: "temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code"),
            URLQueryItem(
                name: "hourly",
                value: "temperature_2m,apparent_temperature,weather_code,precipitation_probability,relative_humidity_2m,wind_speed_10m,precipitation"
            ),
            URLQueryItem(name: "daily", value: "weather_code,temperature_2m_max,temperature_2m_min,relative_humidity_2m_mean,precipitation_probability_max"),
            URLQueryItem(name: "forecast_days", value: "7"),
            URLQueryItem(name: "timezone", value: "Asia/Tokyo"),
            URLQueryItem(name: "elevation", value: String(Self.forecastElevationMeters)),
            URLQueryItem(name: "models", value: Self.forecastModels),
        ]

        components?.queryItems = items

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }
        return url
    }

    private func makeMarineURL(latitude: Double, longitude: Double) throws -> URL {
        var components = URLComponents(string: "https://marine-api.open-meteo.com/v1/marine")
        components?.queryItems = [
            URLQueryItem(name: "latitude", value: String(latitude)),
            URLQueryItem(name: "longitude", value: String(longitude)),
            URLQueryItem(name: "current", value: "wave_height"),
            URLQueryItem(name: "hourly", value: "wave_height"),
            URLQueryItem(name: "forecast_days", value: "1"),
            URLQueryItem(name: "timezone", value: "Asia/Tokyo"),
        ]

        guard let url = components?.url else {
            throw WeatherServiceError.invalidURL
        }
        return url
    }
}

private struct WeatherQuery {
    let latitude: Double
    let longitude: Double
}

enum WeatherServiceError: Error {
    case invalidURL
    case badResponse
}

private struct WaveHeightData {
    let currentMeters: Double?
    let todayMaxMeters: Double?
}

// Open-Meteo のレスポンス（必要な部分だけ）
private struct OpenMeteoResponse: Decodable {
    let current: OpenMeteoCurrent
    let hourly: OpenMeteoHourly
    let daily: OpenMeteoDaily

    func toWeatherInfo(waveHeight: WaveHeightData?) -> WeatherInfo {
        WeatherInfo(
            temperatureCelsius: Int(current.temperature2m.rounded()),
            apparentTemperatureCelsius: current.apparentTemperature.map { Int($0.rounded()) },
            condition: WeatherConditionMapper.japaneseName(for: current.weatherCode),
            humidityPercent: current.relativeHumidity2m,
            windSpeedKmh: Int(current.windSpeed10m.rounded()),
            currentWaveHeightMeters: waveHeight?.currentMeters,
            todayMaxWaveHeightMeters: waveHeight?.todayMaxMeters,
            todayHourlyForecast: hourly.toTodayHourlyForecast(),
            weeklyForecast: daily.toWeeklyForecast(),
            fetchedAt: Date()
        )
    }
}

private struct OpenMeteoMarineResponse: Decodable {
    let current: OpenMeteoMarineCurrent?
    let hourly: OpenMeteoMarineHourly?

    func toWaveHeightData() -> WaveHeightData {
        WaveHeightData(
            currentMeters: current?.waveHeight,
            todayMaxMeters: hourly?.todayMaxWaveHeight()
        )
    }
}

private struct OpenMeteoMarineCurrent: Decodable {
    let waveHeight: Double?

    enum CodingKeys: String, CodingKey {
        case waveHeight = "wave_height"
    }
}

private struct OpenMeteoMarineHourly: Decodable {
    let time: [String]
    let waveHeight: [Double?]

    enum CodingKeys: String, CodingKey {
        case time
        case waveHeight = "wave_height"
    }

    func todayMaxWaveHeight() -> Double? {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let todayPrefix = WeatherDateFormatter.todayDatePrefix(for: Date(), calendar: calendar)
        let safeCount = min(time.count, waveHeight.count)

        let values = (0..<safeCount).compactMap { index -> Double? in
            guard time[index].hasPrefix(todayPrefix) else { return nil }
            return waveHeight[index]
        }

        return values.max()
    }
}

private struct OpenMeteoCurrent: Decodable {
    let temperature2m: Double
    let apparentTemperature: Double?
    let relativeHumidity2m: Int
    let windSpeed10m: Double
    let weatherCode: Int

    enum CodingKeys: String, CodingKey {
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case relativeHumidity2m = "relative_humidity_2m"
        case windSpeed10m = "wind_speed_10m"
        case weatherCode = "weather_code"
    }
}

private struct OpenMeteoHourly: Decodable {
    let time: [String]
    let temperature2m: [Double]
    let apparentTemperature: [Double?]
    let weatherCode: [Int]
    // jma_seamless などで null が返ることがあるため Optional
    let precipitationProbability: [Int?]
    let relativeHumidity2m: [Int]
    let windSpeed10m: [Double]
    let precipitation: [Double]

    enum CodingKeys: String, CodingKey {
        case time
        case temperature2m = "temperature_2m"
        case apparentTemperature = "apparent_temperature"
        case weatherCode = "weather_code"
        case precipitationProbability = "precipitation_probability"
        case relativeHumidity2m = "relative_humidity_2m"
        case windSpeed10m = "wind_speed_10m"
        case precipitation
    }

    func toTodayHourlyForecast(maxHours: Int = 24) -> [HourlyWeatherForecast] {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let now = Date()
        guard let startOfCurrentHour = calendar.date(
            from: calendar.dateComponents([.year, .month, .day, .hour], from: now)
        ) else {
            return []
        }

        var forecasts: [HourlyWeatherForecast] = []
        // API レスポンスで配列長がずれた場合のクラッシュを防ぐ
        let safeCount = [
            time.count,
            temperature2m.count,
            apparentTemperature.count,
            weatherCode.count,
            precipitationProbability.count,
            relativeHumidity2m.count,
            windSpeed10m.count,
            precipitation.count,
        ].min() ?? 0

        for index in 0..<safeCount {
            let timeString = time[index]
            guard let slotDate = WeatherDateFormatter.openMeteoDate(from: timeString, calendar: calendar) else {
                continue
            }
            guard slotDate >= startOfCurrentHour else {
                continue
            }

            let precipitationProb = precipitationProbability[index] ?? 0
            let hour = calendar.component(.hour, from: slotDate)
            let apparentCelsius = apparentTemperature[index].map { Int($0.rounded()) }
            forecasts.append(
                HourlyWeatherForecast(
                    id: timeString,
                    timeLabel: "\(hour)時",
                    temperatureCelsius: Int(temperature2m[index].rounded()),
                    apparentTemperatureCelsius: apparentCelsius,
                    condition: WeatherConditionMapper.japaneseName(for: weatherCode[index]),
                    humidityPercent: relativeHumidity2m[index],
                    precipitationProbabilityPercent: max(0, precipitationProb),
                    precipitationMillimeters: max(0, precipitation[index]),
                    windSpeedKmh: Int(windSpeed10m[index].rounded())
                )
            )

            if forecasts.count >= maxHours {
                break
            }
        }

        return forecasts
    }
}

private struct OpenMeteoDaily: Decodable {
    let time: [String]
    let weatherCode: [Int]
    let temperature2mMax: [Double]
    let temperature2mMin: [Double]
    let relativeHumidity2mMean: [Double]
    let precipitationProbabilityMax: [Int?]

    enum CodingKeys: String, CodingKey {
        case time
        case weatherCode = "weather_code"
        case temperature2mMax = "temperature_2m_max"
        case temperature2mMin = "temperature_2m_min"
        case relativeHumidity2mMean = "relative_humidity_2m_mean"
        case precipitationProbabilityMax = "precipitation_probability_max"
    }

    func toWeeklyForecast() -> [DailyWeatherForecast] {
        // API レスポンスで配列長がずれた場合のクラッシュを防ぐ
        let safeCount = [
            time.count,
            weatherCode.count,
            temperature2mMax.count,
            temperature2mMin.count,
            relativeHumidity2mMean.count,
            precipitationProbabilityMax.count,
        ].min() ?? 0

        return (0..<safeCount).map { index in
            DailyWeatherForecast(
                id: time[index],
                dateLabel: WeatherDateFormatter.label(for: time[index]),
                minTemperatureCelsius: Int(temperature2mMin[index].rounded()),
                maxTemperatureCelsius: Int(temperature2mMax[index].rounded()),
                condition: WeatherConditionMapper.japaneseName(for: weatherCode[index]),
                humidityPercent: Int(relativeHumidity2mMean[index].rounded()),
                precipitationProbabilityPercent: max(0, precipitationProbabilityMax[index] ?? 0)
            )
        }
    }
}

private enum WeatherDateFormatter {
    static func label(for dateString: String) -> String {
        let input = DateFormatter()
        input.dateFormat = "yyyy-MM-dd"
        input.timeZone = TimeZone(identifier: "Asia/Tokyo")

        guard let date = input.date(from: dateString) else {
            return dateString
        }

        let output = DateFormatter()
        output.locale = Locale(identifier: "ja_JP")
        output.dateFormat = "M/d（E）"
        output.timeZone = TimeZone(identifier: "Asia/Tokyo")
        return output.string(from: date)
    }

    static func todayDatePrefix(for date: Date, calendar: Calendar) -> String {
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        guard let year = components.year, let month = components.month, let day = components.day else {
            return ""
        }
        return String(format: "%04d-%02d-%02dT", year, month, day)
    }

    static func openMeteoDate(from timeString: String, calendar: Calendar) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        formatter.timeZone = calendar.timeZone
        return formatter.date(from: timeString)
    }

    static func hour(from isoTime: String) -> Int? {
        // Open-Meteo（Asia/Tokyo）: "2026-06-21T09:00"
        guard isoTime.count >= 13 else { return nil }
        let hourStart = isoTime.index(isoTime.startIndex, offsetBy: 11)
        let hourEnd = isoTime.index(hourStart, offsetBy: 2)
        return Int(isoTime[hourStart..<hourEnd])
    }
}

// WMO天気コードを日本語に変換
private enum WeatherConditionMapper {
    static func japaneseName(for code: Int) -> String {
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
}
