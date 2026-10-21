//
//  FerryPagesTimetable.swift
//  Island Base
//
//  GitHub Pages のフェリー時刻表 JSON（docs/ferry/kutsuna.json）を便に変換する。
//  JSON 内の URL は読まない。リンク先はプロフィールに書いてある固定値だけを使う。
//

import Foundation

struct FerryPagesIslandTimetable {
    let schedules: [FerryCompanySchedule]
    let sourceUpdatedAt: Date
}

enum FerryPagesTimetableError: Error {
    case oversized
    case unsupportedSchema
    case malformed
    case islandMissing
}

enum FerryPagesTimetable {
    static let maxResponseBytes = 256 * 1024
    static let maxTripsPerIsland = 100
    static let supportedSchemaVersion = 1
    /// 3日より古い fetchedAt は古いデータ（ちょうど3日はまだ新しい）
    static let staleInterval: TimeInterval = 3 * 24 * 60 * 60
    static let allowedFileName = "kutsuna"

    static func isStale(sourceUpdatedAt: Date, now: Date = Date()) -> Bool {
        now.timeIntervalSince(sourceUpdatedAt) > staleInterval
    }

    /// CDN 対策: JST の12時間ブロック（YYYYMMDD + 00 または 12）
    static func halfDayBlockString(for date: Date = Date()) -> String {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        guard let year = components.year,
              let month = components.month,
              let day = components.day,
              let hour = components.hour else {
            return "0000000000"
        }
        let blockHour = hour < 12 ? 0 : 12
        return String(format: "%04d%02d%02d%02d", year, month, day, blockHour)
    }

    static func displayTimestamp(_ date: Date, language: AppLanguageMode) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: language.isJapanese ? "ja_JP" : "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        formatter.dateFormat = language.isJapanese ? "M月d日 HH:mm" : "MMM d, HH:mm"
        return formatter.string(from: date)
    }

    /// 時刻のある便だけ数える。運休（時刻なし）はカードの便数に入れない。
    static func scheduledTripCount(in schedules: [FerryCompanySchedule]) -> Int {
        schedules.reduce(0) { count, schedule in
            count + schedule.trips.filter(\.hasScheduledTimes).count
        }
    }

    /// 凡例は高速船と夜航が揃ったときだけ。フェリーと高速船の組み合わせでは出さない。
    static func showsHighSpeedAndOvernightLegend(_ kinds: [FerryServiceKind?]) -> Bool {
        let present = Set(kinds.compactMap { $0 })
        return present.contains(.highSpeedBoat) && present.contains(.overnightFerry)
    }

    /// 松山側の港。公式英語が取れた名前だけ。日本語モードと、それ以外の港は nil。
    static func localizedMainlandPortName(_ japaneseName: String, language: AppLanguageMode) -> String? {
        guard language == .english else { return nil }
        switch japaneseName {
        case "三津浜":
            return "Mitsuhama Port (三津浜)"
        case "高浜":
            return "Takahama Port (高浜)"
        default:
            return nil
        }
    }

    /// 「当面の間運休」を含む既知の文言だけ英訳する。日付は注記から取る。それ以外は原文。
    static func localizedSuspensionNote(_ note: String, language: AppLanguageMode) -> String {
        guard language == .english else { return note }
        if note == "当面の間運休" {
            return "Suspended until further notice"
        }
        guard let since = suspensionSinceText(note) else { return note }
        return "Suspended until further notice (since \(since))"
    }

    /// 東線・西線。知らない文言はそのまま（URL にはしない）
    static func localizedLine(_ raw: String?, language: AppLanguageMode) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.isEmpty == false else { return nil }
        switch trimmed {
        case "東線":
            return language.isJapanese ? "東線" : "East route"
        case "西線":
            return language.isJapanese ? "西線" : "West route"
        default:
            return trimmed
        }
    }

    static func decode(
        data: Data,
        islandID: String,
        company: FerryCompany
    ) throws -> FerryPagesIslandTimetable {
        guard data.count <= maxResponseBytes else {
            throw FerryPagesTimetableError.oversized
        }

        let document: FerryPagesDocument
        do {
            document = try JSONDecoder().decode(FerryPagesDocument.self, from: data)
        } catch {
            throw FerryPagesTimetableError.malformed
        }

        guard document.schemaVersion == supportedSchemaVersion else {
            throw FerryPagesTimetableError.unsupportedSchema
        }

        guard let sourceUpdatedAt = parseFetchedAt(document.fetchedAt) else {
            throw FerryPagesTimetableError.malformed
        }

        guard let rawSchedules = document.islands[islandID] else {
            throw FerryPagesTimetableError.islandMissing
        }

        let schedules = makeSchedules(
            rawSchedules,
            company: company,
            sourceUpdatedAt: sourceUpdatedAt
        )
        return FerryPagesIslandTimetable(
            schedules: schedules,
            sourceUpdatedAt: sourceUpdatedAt
        )
    }

    private static func parseFetchedAt(_ text: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        if let date = formatter.date(from: text) {
            return date
        }
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: text)
    }

    private static func makeSchedules(
        _ rawSchedules: [FerryPagesScheduleDTO],
        company: FerryCompany,
        sourceUpdatedAt: Date
    ) -> [FerryCompanySchedule] {
        var remaining = maxTripsPerIsland
        var schedules: [FerryCompanySchedule] = []

        for raw in rawSchedules {
            if remaining == 0 { break }
            var trips: [FerryTrip] = []
            for (index, rawTrip) in raw.trips.enumerated() {
                if remaining == 0 { break }
                guard let trip = makeTrip(rawTrip, scheduleID: raw.id, index: index) else { continue }
                trips.append(trip)
                remaining -= 1
            }
            guard trips.isEmpty == false else { continue }

            let scheduleID = raw.id.trimmingCharacters(in: .whitespacesAndNewlines)
            schedules.append(
                FerryCompanySchedule(
                    id: scheduleID.isEmpty ? "kutsuna-\(schedules.count)" : scheduleID,
                    company: company,
                    trips: trips,
                    serviceKind: serviceKind(for: raw.kind),
                    lineLabel: normalizedLine(raw.line),
                    sourceUpdatedAt: sourceUpdatedAt,
                    showsOperatorActions: false
                )
            )
        }

        return schedules
    }

    private static func makeTrip(
        _ raw: FerryPagesTripDTO,
        scheduleID: String,
        index: Int
    ) -> FerryTrip? {
        let from = routePlaceName(raw.from)
        let to = routePlaceName(raw.to)
        guard from.isEmpty == false, to.isEmpty == false else { return nil }
        let departureIslandID = islandID(forPort: raw.from)
        let arrivalIslandID = islandID(forPort: raw.to)

        let departure = scheduledTime(raw.departure)
        let arrival = scheduledTime(raw.arrival)
        let note = normalizedNote(raw.note)
        let hasBothTimes = departure != nil && arrival != nil
        guard hasBothTimes || note != nil else { return nil }

        let idPrefix = scheduleID.trimmingCharacters(in: .whitespacesAndNewlines)
        let tripID = idPrefix.isEmpty ? "trip-\(index)" : "\(idPrefix)-\(index)"
        return FerryTrip(
            id: tripID,
            routeName: "\(from) → \(to)",
            departureTime: hasBothTimes ? departure ?? "" : "",
            arrivalTime: hasBothTimes ? arrival ?? "" : "",
            note: note,
            departureIslandID: departureIslandID,
            arrivalIslandID: arrivalIslandID
        )
    }

    /// 「8:05」も「08:05」も時刻として受け、それ以外は時刻なしにする
    private static func scheduledTime(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let text = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = text.split(separator: ":")
        guard parts.count == 2,
              parts[0].count <= 2,
              parts[1].count == 2,
              parts[0].allSatisfy(\.isNumber),
              parts[1].allSatisfy(\.isNumber),
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0..<24).contains(hour),
              (0..<60).contains(minute) else {
            return nil
        }
        return String(format: "%02d:%02d", hour, minute)
    }

    private static func normalizedNote(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func normalizedLine(_ raw: String?) -> String? {
        guard let raw else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }

    private static func serviceKind(for raw: String?) -> FerryServiceKind? {
        switch raw {
        case "ferry":
            return .ferry
        case "highspeed":
            return .highSpeedBoat
        default:
            return nil
        }
    }

    /// `2025年2月1日から当面の間運休` だけ日付を取り出す。余計な文字や実在しない日は nil。
    private static func suspensionSinceText(_ note: String) -> String? {
        let marker = "日から当面の間運休"
        guard note.hasSuffix(marker) else { return nil }
        let head = note.dropLast(marker.count)
        let yearParts = head.split(separator: "年", omittingEmptySubsequences: false)
        guard yearParts.count == 2,
              yearParts[0].count == 4,
              yearParts[0].allSatisfy(\.isNumber),
              let year = Int(yearParts[0]) else {
            return nil
        }
        let monthParts = yearParts[1].split(separator: "月", omittingEmptySubsequences: false)
        guard monthParts.count == 2,
              monthParts[0].isEmpty == false,
              monthParts[0].count <= 2,
              monthParts[0].allSatisfy(\.isNumber),
              let month = Int(monthParts[0]),
              (1...12).contains(month),
              monthParts[1].isEmpty == false,
              monthParts[1].count <= 2,
              monthParts[1].allSatisfy(\.isNumber),
              let day = Int(monthParts[1]) else {
            return nil
        }

        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let components = DateComponents(year: year, month: month, day: day)
        guard let date = calendar.date(from: components),
              calendar.component(.year, from: date) == year,
              calendar.component(.month, from: date) == month,
              calendar.component(.day, from: date) == day else {
            return nil
        }

        let months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"]
        return "\(months[month - 1]) \(day), \(year)"
    }

    /// 時刻表の港名を島 ID にする。松山側（高浜・三津浜）は nil。JSON の URL は使わない
    private static func islandID(forPort raw: String) -> String? {
        switch raw.trimmingCharacters(in: .whitespacesAndNewlines) {
        case "大浦", "神浦", "西中":
            return "nakajima"
        case "睦月":
            return "muzukijima"
        case "野忽那":
            return "nogutsunajima"
        case "上怒和", "元怒和":
            return "nuwajima"
        case "津和地":
            return "tsuwajishima"
        case "二神":
            return "futagamijima"
        case "釣島":
            return "tsurushima"
        default:
            return nil
        }
    }

    /// 島側の港は IslandPort.name に合わせる。松山側（高浜・三津浜など）はそのまま。
    private static func routePlaceName(_ raw: String) -> String {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        switch trimmed {
        case "大浦":
            return "大浦港"
        case "神浦":
            return "神浦港"
        case "西中":
            return "西中港"
        case "睦月":
            return "睦月港"
        case "野忽那":
            return "野忽那港"
        case "上怒和":
            return "上怒和港"
        case "元怒和":
            return "元怒和港"
        case "津和地":
            return "津和地港"
        case "二神":
            return "二神港"
        case "釣島":
            return "釣島港"
        default:
            return trimmed
        }
    }
}

// source.url は意図的にデコードしない（JSON の文字列からリンクを作らない）
private struct FerryPagesDocument: Decodable {
    let schemaVersion: Int
    let fetchedAt: String
    let islands: [String: [FerryPagesScheduleDTO]]
}

private struct FerryPagesScheduleDTO: Decodable {
    let id: String
    let line: String?
    let kind: String?
    let trips: [FerryPagesTripDTO]
}

private struct FerryPagesTripDTO: Decodable {
    let from: String
    let to: String
    let departure: String?
    let arrival: String?
    let note: String?
}
