//
//  HourlyForecastClock.swift
//  Island Base
//
//  24時間予報の「今」を端末の日本時間に合わせる
//

import Foundation

enum HourlyForecastClock {
    private static let jst = TimeZone(identifier: "Asia/Tokyo") ?? .gmt

    private static let slotFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = jst
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
        return formatter
    }()

    /// Open-Meteo 形式の hourly id（例: 2026-09-08T20:00）
    static func slotDate(from id: String) -> Date? {
        slotFormatter.date(from: id)
    }

    static func startOfHour(_ date: Date) -> Date {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = jst
        let parts = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return calendar.date(from: parts) ?? date
    }

    static func isCurrentHour(_ slot: HourlyWeatherForecast, now: Date) -> Bool {
        guard let date = slotDate(from: slot.id) else { return false }
        return startOfHour(date) == startOfHour(now)
    }

    /// いまの時刻以降の枠だけ残す（過去の「今」を出さない）
    static func remainingSlots(_ slots: [HourlyWeatherForecast], now: Date) -> [HourlyWeatherForecast] {
        let start = startOfHour(now)
        return slots.filter { slot in
            guard let date = slotDate(from: slot.id) else { return true }
            return date >= start
        }
    }

    static func currentHourSlot(_ slots: [HourlyWeatherForecast], now: Date) -> HourlyWeatherForecast? {
        slots.first { isCurrentHour($0, now: now) }
    }
}
