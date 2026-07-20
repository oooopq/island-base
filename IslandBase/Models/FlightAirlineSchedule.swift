//
//  FlightAirlineSchedule.swift
//  Island Base
//
//  航空会社1社分の便一覧
//

import Foundation

struct FlightAirlineSchedule: Identifiable, Codable {
    let id: String
    let airline: FlightAirline
    let trips: [FlightTrip]
}
