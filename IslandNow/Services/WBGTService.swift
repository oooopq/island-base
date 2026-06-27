//
//  WBGTService.swift
//  Island Now
//
//  環境省 熱中症予防情報サイト API から WBGT を取得する
//

import Foundation

struct WBGTService {
    private let cacheKeyPrefix = "wbgt_cache_"
    private static let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current

    func fetchRisk(stationNo: Int, islandID: String) async throws -> HeatStrokeRiskInfo? {
        guard Self.isInSeason else { return nil }

        let now = Date()
        let dateFrom = Self.apiTimestamp(for: Self.startOfDay(for: now))
        let dateTo = Self.apiTimestamp(for: Self.endOfDay(for: now))

        async let forecastData = fetchForecast(stationNo: stationNo, from: dateFrom, to: dateTo)
        async let surveyData = fetchSurvey(stationNo: stationNo, from: dateFrom, to: dateTo)

        let forecast = try await forecastData
        let survey = try await surveyData

        guard let todayMaxWBGT = forecast.todayMaxWBGT(referenceDate: now) else {
            throw WBGTServiceError.noData
        }

        let risk = HeatStrokeRiskInfo(
            currentWBGT: survey.currentWBGT(referenceDate: now) ?? forecast.currentWBGT(referenceDate: now),
            todayMaxWBGT: todayMaxWBGT
        )
        saveCache(risk, for: islandID)
        return risk
    }

    func cachedRisk(for islandID: String) -> HeatStrokeRiskInfo? {
        guard Self.isInSeason else { return nil }
        let key = cacheKeyPrefix + islandID
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(HeatStrokeRiskInfo.self, from: data)
    }

    static var isInSeason: Bool {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tokyoTimeZone
        let now = Date()
        let month = calendar.component(.month, from: now)
        let day = calendar.component(.day, from: now)

        if month < 4 || month > 10 { return false }
        if month == 4 && day < 22 { return false }
        if month == 10 && day > 21 { return false }
        return true
    }

    private func fetchForecast(stationNo: Int, from: String, to: String) async throws -> WBGTForecastResponse {
        var components = URLComponents(string: "https://www.wbgt.env.go.jp/api/v1/getForecastData")
        components?.queryItems = [
            URLQueryItem(name: "data_type", value: "0"),
            URLQueryItem(name: "location_type", value: "1"),
            URLQueryItem(name: "wbgt_nos", value: String(stationNo)),
            URLQueryItem(name: "date_search_type", value: "1"),
            URLQueryItem(name: "range_date_from", value: from),
            URLQueryItem(name: "range_date_to", value: to),
        ]

        guard let url = components?.url else { throw WBGTServiceError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WBGTServiceError.badResponse
        }

        let decoded = try JSONDecoder().decode(WBGTAPIEnvelope<WBGTForecastRecord>.self, from: data)
        guard decoded.status == "success" else { throw WBGTServiceError.noData }
        return WBGTForecastResponse(records: decoded.data)
    }

    private func fetchSurvey(stationNo: Int, from: String, to: String) async throws -> WBGTSurveyResponse {
        var components = URLComponents(string: "https://www.wbgt.env.go.jp/api/v1/getSurveyData")
        components?.queryItems = [
            URLQueryItem(name: "data_type", value: "0"),
            URLQueryItem(name: "location_type", value: "1"),
            URLQueryItem(name: "wbgt_nos", value: String(stationNo)),
            URLQueryItem(name: "date_from", value: from),
            URLQueryItem(name: "date_to", value: to),
        ]

        guard let url = components?.url else { throw WBGTServiceError.invalidURL }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw WBGTServiceError.badResponse
        }

        let decoded = try JSONDecoder().decode(WBGTAPIEnvelope<WBGTSurveyRecord>.self, from: data)
        guard decoded.status == "success" else { throw WBGTServiceError.noData }
        return WBGTSurveyResponse(records: decoded.data)
    }

    private func saveCache(_ risk: HeatStrokeRiskInfo, for islandID: String) {
        guard let data = try? JSONEncoder().encode(risk) else { return }
        UserDefaults.standard.set(data, forKey: cacheKeyPrefix + islandID)
    }

    private static func startOfDay(for date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tokyoTimeZone
        return calendar.startOfDay(for: date)
    }

    private static func endOfDay(for date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tokyoTimeZone
        let start = calendar.startOfDay(for: date)
        return calendar.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? date
    }

    private static func apiTimestamp(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "yyyyMMddHHmmss"
        return formatter.string(from: date)
    }
}

enum WBGTServiceError: Error {
    case invalidURL
    case badResponse
    case noData
}

private struct WBGTAPIEnvelope<T: Decodable>: Decodable {
    let status: String
    let data: [T]
}

private struct WBGTForecastRecord: Decodable {
    let forecastVal: String
    let forecastTime: String

    enum CodingKeys: String, CodingKey {
        case forecastVal = "forecast_val"
        case forecastTime = "forecast_time"
    }
}

private struct WBGTSurveyRecord: Decodable {
    let wbgtDate: String
    let wbgtWO: String

    enum CodingKeys: String, CodingKey {
        case wbgtDate = "wbgt_date"
        case wbgtWO = "wbgt_WO"
    }
}

private struct WBGTForecastResponse {
    let records: [WBGTForecastRecord]

    func todayMaxWBGT(referenceDate: Date) -> Double? {
        let todayPrefix = WBGTDateParser.todayPrefix(for: referenceDate)
        let values = records.compactMap { record -> Double? in
            guard record.forecastTime.hasPrefix(todayPrefix) else { return nil }
            return WBGTDateParser.forecastValue(from: record.forecastVal)
        }
        return values.max()
    }

    func currentWBGT(referenceDate: Date) -> Double? {
        let todayPrefix = WBGTDateParser.todayPrefix(for: referenceDate)
        let now = referenceDate
        let candidates = records.compactMap { record -> (Date, Double)? in
            guard record.forecastTime.hasPrefix(todayPrefix),
                  let date = WBGTDateParser.parseDateTime(record.forecastTime),
                  let value = WBGTDateParser.forecastValue(from: record.forecastVal) else {
                return nil
            }
            return (date, value)
        }
        return candidates
            .filter { $0.0 <= now }
            .max(by: { $0.0 < $1.0 })?
            .1
    }
}

private struct WBGTSurveyResponse {
    let records: [WBGTSurveyRecord]

    func currentWBGT(referenceDate: Date) -> Double? {
        let todayPrefix = WBGTDateParser.todayPrefix(for: referenceDate)
        let now = referenceDate
        let candidates = records.compactMap { record -> (Date, Double)? in
            guard record.wbgtDate.hasPrefix(todayPrefix),
                  let date = WBGTDateParser.parseDateTime(record.wbgtDate),
                  let value = Double(record.wbgtWO) else {
                return nil
            }
            return (date, value)
        }
        return candidates
            .filter { $0.0 <= now }
            .max(by: { $0.0 < $1.0 })?
            .1
    }
}

private enum WBGTDateParser {
    private static let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current

    static func parseDateTime(_ value: String) -> Date? {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
        return formatter.date(from: value)
    }

    static func todayPrefix(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = tokyoTimeZone
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter.string(from: date)
    }

    static func forecastValue(from raw: String) -> Double? {
        guard let scaled = Double(raw) else { return nil }
        return scaled / 10.0
    }
}
