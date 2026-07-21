//
//  GTFSFerryParser.swift
//  Island Base
//
//  GTFSのCSVからフェリーダイヤを組み立てる
//

import Foundation

struct GTFSFerryParser {
    func parseTrips(from files: [String: String], islandID: String) -> [FerryTrip] {
        guard let routesText = files["routes.txt"],
              let tripsText = files["trips.txt"],
              let stopTimesText = files["stop_times.txt"],
              let stopsText = files["stops.txt"] else {
            return []
        }

        let routes = parseCSV(routesText)
        let trips = parseCSV(tripsText)
        let stopTimes = parseCSV(stopTimesText)
        let stops = parseCSV(stopsText)
        let calendar = files["calendar.txt"].map(parseCSV) ?? []
        let calendarDates = files["calendar_dates.txt"].map(parseCSV) ?? []

        let activeServiceIDs = activeServiceIDs(calendarRows: calendar, calendarDates: calendarDates)
        let routesByID = Dictionary(uniqueKeysWithValues: routes.compactMap { row -> (String, [String: String])? in
            guard let routeID = row["route_id"] else { return nil }
            return (routeID, row)
        })
        let stopNameByID = Dictionary(uniqueKeysWithValues: stops.compactMap { row -> (String, String)? in
            guard let stopID = row["stop_id"], let stopName = row["stop_name"] else { return nil }
            return (stopID, stopName)
        })

        let stopTimesByTrip = Dictionary(grouping: stopTimes) { $0["trip_id"] ?? "" }

        var ferryTrips: [FerryTrip] = []

        for trip in trips {
            guard let tripID = trip["trip_id"],
                  let routeID = trip["route_id"],
                  let serviceID = trip["service_id"],
                  activeServiceIDs.contains(serviceID),
                  let route = routesByID[routeID],
                  let routeLongName = route["route_long_name"],
                  IslandCatalog.profile(for: islandID)?.matchesRoute(routeLongName) == true,
                  let stopTimeRows = stopTimesByTrip[tripID] else {
                continue
            }

            let sortedStops = stopTimeRows.sorted {
                Int($0["stop_sequence"] ?? "0") ?? 0 < Int($1["stop_sequence"] ?? "0") ?? 0
            }

            guard let first = sortedStops.first,
                  let last = sortedStops.last,
                  let departureRaw = first["departure_time"],
                  let arrivalRaw = last["arrival_time"],
                  let fromStopID = first["stop_id"],
                  let toStopID = last["stop_id"],
                  let fromName = stopNameByID[fromStopID],
                  let toName = stopNameByID[toStopID] else {
                continue
            }

            let departureTime = formatTime(departureRaw)
            let arrivalTime = formatTime(arrivalRaw)
            let routeName = "\(fromName) → \(toName)"

            ferryTrips.append(
                FerryTrip(
                    id: tripID,
                    routeName: routeName,
                    departureTime: departureTime,
                    arrivalTime: arrivalTime
                )
            )
        }

        return deduplicatedAndSorted(ferryTrips)
    }

    func validUntilText(from files: [String: String]) -> String? {
        guard let feedInfoText = files["feed_info.txt"] else { return nil }
        let rows = parseCSV(feedInfoText)
        guard let endDate = rows.first?["feed_end_date"], endDate.isEmpty == false else { return nil }
        return formatFeedDate(endDate)
    }

    private func parseCSV(_ text: String) -> [[String: String]] {
        let cleaned = text.hasPrefix("\u{FEFF}") ? String(text.dropFirst()) : text
        let lines = cleaned.split(whereSeparator: \.isNewline).map(String.init)
        guard let headerLine = lines.first else { return [] }

        let headers = headerLine.split(separator: ",").map { String($0) }
        var rows: [[String: String]] = []

        for line in lines.dropFirst() where line.isEmpty == false {
            let values = line.split(separator: ",", omittingEmptySubsequences: false).map { String($0) }
            var row: [String: String] = [:]
            for (index, header) in headers.enumerated() where index < values.count {
                row[header] = values[index]
            }
            rows.append(row)
        }

        return rows
    }

    private func activeServiceIDs(calendarRows: [[String: String]], calendarDates: [[String: String]]) -> Set<String> {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        let today = calendar.startOfDay(for: Date())
        let todayNumber = calendar.component(.year, from: today) * 10_000
            + calendar.component(.month, from: today) * 100
            + calendar.component(.day, from: today)

        var removedServices = Set<String>()
        var addedServices = Set<String>()

        for row in calendarDates {
            guard let serviceID = row["service_id"],
                  let dateString = row["date"],
                  let exceptionType = row["exception_type"],
                  let dateNumber = Int(dateString),
                  dateNumber == todayNumber else {
                continue
            }

            if exceptionType == "2" {
                removedServices.insert(serviceID)
            } else if exceptionType == "1" {
                addedServices.insert(serviceID)
            }
        }

        // 曜日・例外の前に「今日を覆う期間があるか」を判定する
        let coveringRows = calendarRows.filter { row in
            guard let startDate = Int(row["start_date"] ?? ""),
                  let endDate = Int(row["end_date"] ?? "") else {
                return false
            }
            return todayNumber >= startDate && todayNumber <= endDate
        }
        let hasCoveringPeriod = coveringRows.isEmpty == false

        let weekday = calendar.component(.weekday, from: today)
        let weekdayKey: String
        switch weekday {
        case 1: weekdayKey = "sunday"
        case 2: weekdayKey = "monday"
        case 3: weekdayKey = "tuesday"
        case 4: weekdayKey = "wednesday"
        case 5: weekdayKey = "thursday"
        case 6: weekdayKey = "friday"
        default: weekdayKey = "saturday"
        }

        var activeServices = Set<String>()
        for row in coveringRows {
            guard let serviceID = row["service_id"], row[weekdayKey] == "1" else { continue }
            activeServices.insert(serviceID)
        }

        activeServices.subtract(removedServices)
        activeServices.formUnion(addedServices)

        // 運休などで空になった場合は空のまま返す。フォールバックは期間切れのときだけ。
        if activeServices.isEmpty == false || hasCoveringPeriod {
            return activeServices
        }

        return fallbackServiceIDs(calendarRows: calendarRows, todayNumber: todayNumber)
    }

    // 終了日が今日以前で、いちばん新しいダイヤ期間を選ぶ（OTTOP更新待ち用）
    private func fallbackServiceIDs(calendarRows: [[String: String]], todayNumber: Int) -> Set<String> {
        let eligibleRows = calendarRows.filter { row in
            guard let endDate = Int(row["end_date"] ?? "") else { return false }
            return endDate <= todayNumber
        }

        guard let latestEndDate = eligibleRows.compactMap({ Int($0["end_date"] ?? "") }).max() else {
            // 期間切れでも終了済み期間が無いときは、全サービスを出さず空にする
            return []
        }

        return Set(
            eligibleRows
                .filter { Int($0["end_date"] ?? "") == latestEndDate }
                .compactMap { $0["service_id"] }
        )
    }

    private func formatTime(_ raw: String) -> String {
        String(raw.prefix(5))
    }

    private func formatFeedDate(_ raw: String) -> String {
        guard raw.count == 8 else { return raw }
        let year = raw.prefix(4)
        let month = raw.dropFirst(4).prefix(2)
        let day = raw.suffix(2)
        return "\(year)/\(month)/\(day)"
    }

    private func deduplicatedAndSorted(_ trips: [FerryTrip]) -> [FerryTrip] {
        var seen = Set<String>()
        let unique = trips.filter { trip in
            let key = "\(trip.routeName)-\(trip.departureTime)-\(trip.arrivalTime)"
            return seen.insert(key).inserted
        }

        return unique.sorted { $0.departureTime < $1.departureTime }
    }
}
