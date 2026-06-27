//
//  NextDepartureHelper.swift
//  Island Now
//
//  今時刻から見て次に出る便を探す
//

import Foundation

struct UpcomingDeparture: Identifiable, Hashable {
    let id: String
    let routeText: String
    let departureTime: String
    let arrivalTime: String
    let detailText: String?
}

enum NextDepartureHelper {
    private static let tokyoTimeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
    static let departureUrgentThresholdMinutes = 30

    // 「08:30」形式を分に変換する
    static func minutesSinceMidnight(for time: String) -> Int? {
        let parts = time.split(separator: ":")
        guard parts.count == 2,
              let hour = Int(parts[0]),
              let minute = Int(parts[1]),
              (0..<24).contains(hour),
              (0..<60).contains(minute) else {
            return nil
        }
        return hour * 60 + minute
    }

    static func currentMinutesInTokyo() -> Int {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = tokyoTimeZone
        let now = Date()
        return calendar.component(.hour, from: now) * 60 + calendar.component(.minute, from: now)
    }

    // この島を出発するフェリーの次の便（最大2件）
    static func nextFerryDepartures(
        from schedules: [FerryCompanySchedule],
        islandID: String,
        destinationID: String,
        limit: Int = 2
    ) -> [UpcomingDeparture] {
        let candidates = schedules.flatMap { schedule in
            FerryRouteHelper.filteredTrips(
                schedule.trips,
                destinationID: destinationID,
                currentIslandID: islandID
            )
            .compactMap { trip -> (FerryTrip, String?)? in
                guard departsFromCurrentIsland(trip: trip, islandID: islandID) else { return nil }
                return (trip, schedule.company.name)
            }
        }

        return upcoming(from: candidates, limit: limit) { trip, companyName in
            UpcomingDeparture(
                id: "ferry-\(trip.id)",
                routeText: trip.routeName,
                departureTime: trip.departureTime,
                arrivalTime: trip.arrivalTime,
                detailText: companyName
            )
        }
    }

    // この島を出発する航空便の次の便（最大2件）
    static func nextFlightDepartures(
        from schedules: [FlightAirlineSchedule],
        islandID: String,
        destinationID: String,
        limit: Int = 2
    ) -> [UpcomingDeparture] {
        let candidates = schedules.flatMap { schedule in
            FlightRouteHelper.filteredTrips(
                schedule.trips,
                destinationID: destinationID,
                currentIslandID: islandID
            )
            .compactMap { trip -> (FlightTrip, String?)? in
                guard departsFromCurrentIsland(trip: trip, islandID: islandID) else { return nil }
                return (trip, trip.flightNumber)
            }
        }

        return upcoming(from: candidates, limit: limit) { trip, flightNumber in
            UpcomingDeparture(
                id: "flight-\(trip.id)",
                routeText: trip.routeName,
                departureTime: trip.departureTime,
                arrivalTime: trip.arrivalTime,
                detailText: flightNumber
            )
        }
    }

    static func departsFromCurrentIsland(trip: FerryTrip, islandID: String) -> Bool {
        guard let route = FerryRouteHelper.parseRoute(trip.routeName) else { return false }
        return FerryRouteHelper.islandID(for: route.departure) == islandID
    }

    static func departsFromCurrentIsland(trip: FlightTrip, islandID: String) -> Bool {
        guard let route = FlightRouteHelper.parseRoute(trip.routeName) else { return false }
        return FlightRouteHelper.endpointID(for: route.departure) == islandID
    }

    private static func upcoming<T>(
        from candidates: [(T, String?)],
        limit: Int,
        makeDeparture: (T, String?) -> UpcomingDeparture
    ) -> [UpcomingDeparture] {
        let now = currentMinutesInTokyo()

        let sorted = candidates.compactMap { trip, detail -> (Int, UpcomingDeparture)? in
            let departure = makeDeparture(trip, detail)
            guard let minutes = minutesSinceMidnight(for: departure.departureTime) else { return nil }
            return (minutes, departure)
        }
        .sorted { $0.0 < $1.0 }

        let remaining = sorted.filter { $0.0 > now }.prefix(limit).map(\.1)
        if remaining.isEmpty == false {
            return Array(remaining)
        }

        // 本日の便が終わっていれば、翌日の最初の便を表示
        return Array(sorted.prefix(limit).map(\.1))
    }

    static func isTodayFinished(_ departures: [UpcomingDeparture]) -> Bool {
        guard let first = departures.first,
              let minutes = minutesSinceMidnight(for: first.departureTime) else {
            return false
        }
        return minutes <= currentMinutesInTokyo()
    }

    static func minutesUntilDeparture(departureTime: String, isTomorrow: Bool) -> Int? {
        guard let departureMinutes = minutesSinceMidnight(for: departureTime) else { return nil }
        let now = currentMinutesInTokyo()

        if isTomorrow {
            return (24 * 60 - now) + departureMinutes
        }

        let diff = departureMinutes - now
        return diff > 0 ? diff : nil
    }

    static func travelDurationMinutes(departureTime: String, arrivalTime: String) -> Int? {
        guard let departureMinutes = minutesSinceMidnight(for: departureTime),
              let arrivalMinutes = minutesSinceMidnight(for: arrivalTime) else {
            return nil
        }

        if arrivalMinutes >= departureMinutes {
            return arrivalMinutes - departureMinutes
        }
        return (24 * 60 - departureMinutes) + arrivalMinutes
    }

    static func formattedCountdown(_ minutes: Int) -> String {
        if minutes < 60 {
            return "\(minutes)分"
        }

        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        if remainingMinutes == 0 {
            return "\(hours)時間"
        }
        return "\(hours)時間\(remainingMinutes)分"
    }

    static func formattedDuration(_ minutes: Int) -> String {
        formattedCountdown(minutes)
    }

    static func isDepartureUrgent(countdownMinutes: Int?, isTomorrow: Bool) -> Bool {
        guard isTomorrow == false, let countdownMinutes else { return false }
        return countdownMinutes <= departureUrgentThresholdMinutes
    }
}
