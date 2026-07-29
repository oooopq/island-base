//
//  WeatherLabelFormatter.swift
//  Island Base
//
//  天気 JSON の id から言語別の日付・時刻ラベルを組み立てる
//

import Foundation

enum WeatherLabelFormatter {
    private static let jst = TimeZone(identifier: "Asia/Tokyo") ?? .current
    private static let weekdaysJapanese = ["月", "火", "水", "木", "金", "土", "日"]

    static func hourlyTimeLabel(
        from id: String,
        fallback: String,
        language: AppLanguageMode,
        isNow: Bool
    ) -> String {
        if isNow {
            return AppText.nowTimeLabel.string(for: language)
        }

        guard let hour = parseHour(from: id) else {
            return fallback
        }

        if language.isJapanese {
            return "\(hour)時"
        }

        return englishHourLabel(hour)
    }

    static func dailyDateLabel(
        from id: String,
        fallback: String,
        language: AppLanguageMode
    ) -> String {
        guard let date = parseDate(from: id) else {
            return fallback
        }

        if language.isJapanese {
            let weekday = weekdaysJapanese[date.weekdayIndex]
            return "\(date.month)/\(date.day)（\(weekday)）"
        }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = jst
        formatter.dateFormat = "EEE M/d"
        return formatter.string(from: date.foundationDate)
    }

    private static func parseHour(from id: String) -> Int? {
        guard let timePart = id.split(separator: "T").last else {
            return nil
        }
        let hourPart = timePart.split(separator: ":").first
        guard let hourPart, let hour = Int(hourPart), (0..<24).contains(hour) else {
            return nil
        }
        return hour
    }

    private struct ParsedDate {
        let month: Int
        let day: Int
        let weekdayIndex: Int
        let foundationDate: Date
    }

    private static func parseDate(from id: String) -> ParsedDate? {
        let parts = id.split(separator: "-")
        guard parts.count == 3,
              let year = Int(parts[0]),
              let month = Int(parts[1]),
              let day = Int(parts[2]) else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = jst
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components) else {
            return nil
        }

        let weekday = calendar.component(.weekday, from: date)
        // Calendar.weekday: 1=日 … 7=土 → 月曜始まり index
        let weekdayIndex = (weekday + 5) % 7
        return ParsedDate(month: month, day: day, weekdayIndex: weekdayIndex, foundationDate: date)
    }

    private static func englishHourLabel(_ hour: Int) -> String {
        switch hour {
        case 0:
            return "12 AM"
        case 12:
            return "12 PM"
        case 1..<12:
            return "\(hour) AM"
        default:
            return "\(hour - 12) PM"
        }
    }
}
