//
//  FlightRouteHelper.swift
//  Island Now
//
//  航空便の航路から行き先を判別し、絞り込む
//

import Foundation

struct FlightDestination: Identifiable, Hashable {
    let id: String
    let nameJapanese: String
}

enum FlightRouteHelper {
    static let allDestinationsID = "all"

    // 「石垣 → 竹富」形式を出発地と到着地に分ける
    static func parseRoute(_ routeName: String) -> (departure: String, arrival: String)? {
        let separator = " → "
        guard let range = routeName.range(of: separator) else { return nil }

        let departure = String(routeName[..<range.lowerBound]).trimmingCharacters(in: .whitespaces)
        let arrival = String(routeName[range.upperBound...]).trimmingCharacters(in: .whitespaces)

        guard departure.isEmpty == false, arrival.isEmpty == false else { return nil }
        return (departure, arrival)
    }

    static func endpointID(for placeName: String) -> String? {
        if let islandID = IslandCatalog.islandID(matchingPlaceName: placeName) {
            return islandID
        }
        return FlightEndpointCatalog.endpointID(matchingPlaceName: placeName)
    }

    static func partnerEndpointID(for trip: FlightTrip, currentIslandID: String) -> String? {
        guard let route = parseRoute(trip.routeName) else { return nil }

        let departureID = endpointID(for: route.departure)
        let arrivalID = endpointID(for: route.arrival)

        if departureID == currentIslandID {
            return arrivalID
        }
        if arrivalID == currentIslandID {
            return departureID
        }

        return arrivalID ?? departureID
    }

    static func destinations(in schedules: [FlightAirlineSchedule], currentIslandID: String) -> [FlightDestination] {
        var endpointIDs = Set<String>()

        for schedule in schedules {
            for trip in schedule.trips {
                if let partnerID = partnerEndpointID(for: trip, currentIslandID: currentIslandID) {
                    endpointIDs.insert(partnerID)
                }
            }
        }

        return endpointIDs
            .sorted { displayName(for: $0) < displayName(for: $1) }
            .map { FlightDestination(id: $0, nameJapanese: displayName(for: $0)) }
    }

    static func displayName(for endpointID: String) -> String {
        if let islandName = IslandCatalog.profile(for: endpointID)?.island.nameJapanese {
            return islandName
        }
        if let externalName = FlightEndpointCatalog.displayName(for: endpointID) {
            return externalName
        }
        return endpointID
    }

    static func filteredTrips(_ trips: [FlightTrip], destinationID: String, currentIslandID: String) -> [FlightTrip] {
        guard destinationID != allDestinationsID else { return trips }

        return trips.filter { trip in
            partnerEndpointID(for: trip, currentIslandID: currentIslandID) == destinationID
        }
    }
}
