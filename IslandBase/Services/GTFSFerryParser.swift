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
        let routesByID = rowDictionary(rows: routes, idKey: "route_id")
        let stopNameByID = stringDictionary(rows: stops, idKey: "stop_id", valueKey: "stop_name")

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

            ferryTrips.append(
                contentsOf: tripsTouchingIsland(
                    tripID: tripID,
                    sortedStops: sortedStops,
                    stopNameByID: stopNameByID,
                    islandID: islandID
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

    /// uniqueKeysWithValues は重複キーでクラッシュするため、先勝ちで辞書化する
    private func rowDictionary(rows: [[String: String]], idKey: String) -> [String: [String: String]] {
        var result: [String: [String: String]] = [:]
        for row in rows {
            guard let id = row[idKey], result[id] == nil else { continue }
            result[id] = row
        }
        return result
    }

    private func stringDictionary(
        rows: [[String: String]],
        idKey: String,
        valueKey: String
    ) -> [String: String] {
        var result: [String: String] = [:]
        for row in rows {
            guard let id = row[idKey], let value = row[valueKey], result[id] == nil else { continue }
            result[id] = value
        }
        return result
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

    /// 今見ている島の港が途中停泊なら、その港を発着に付け替える。
    /// 八重山観光フェリーの「石垣→鳩間→上原」を鳩間画面で 石垣→鳩間 / 鳩間→上原 と出すため。
    /// 終着が島の港（西表の上原など）なら、従来どおり始発→終着のまま。
    private func tripsTouchingIsland(
        tripID: String,
        sortedStops: [[String: String]],
        stopNameByID: [String: String],
        islandID: String
    ) -> [FerryTrip] {
        let calls = stopCalls(from: sortedStops, stopNameByID: stopNameByID)
        guard calls.count >= 2 else { return [] }

        let islandIndices = calls.indices.filter { index in
            IslandCatalog.profile(for: islandID)?.matchesPlaceName(calls[index].name) == true
        }

        if let islandIndex = islandIndices.first,
           islandIndex > 0,
           islandIndex < calls.count - 1 {
            return [
                ferryTrip(id: "\(tripID)-in", from: calls[islandIndex - 1], to: calls[islandIndex]),
                ferryTrip(id: "\(tripID)-out", from: calls[islandIndex], to: calls[islandIndex + 1]),
            ].compactMap { $0 }
        }

        return [
            ferryTrip(id: tripID, from: calls[0], to: calls[calls.count - 1])
        ].compactMap { $0 }
    }

    private struct StopCall {
        let id: String
        let name: String
        let arrivalTime: String
        let departureTime: String
    }

    private func stopCalls(
        from sortedStops: [[String: String]],
        stopNameByID: [String: String]
    ) -> [StopCall] {
        sortedStops.compactMap { row in
            guard let stopID = row["stop_id"],
                  let name = stopNameByID[stopID] else {
                return nil
            }
            let arrival = row["arrival_time"].flatMap { $0.isEmpty ? nil : $0 }
                ?? row["departure_time"]
                ?? ""
            let departure = row["departure_time"].flatMap { $0.isEmpty ? nil : $0 }
                ?? row["arrival_time"]
                ?? ""
            guard arrival.isEmpty == false, departure.isEmpty == false else { return nil }
            return StopCall(id: stopID, name: name, arrivalTime: arrival, departureTime: departure)
        }
    }

    private func ferryTrip(id: String, from: StopCall, to: StopCall) -> FerryTrip? {
        guard from.id != to.id else { return nil }
        return FerryTrip(
            id: id,
            routeName: "\(from.name) → \(to.name)",
            departureTime: formatTime(from.departureTime),
            arrivalTime: formatTime(to.arrivalTime)
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
