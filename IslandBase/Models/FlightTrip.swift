//
//  FlightTrip.swift
//  Island Base
//
//  航空便1便分の情報
//

import Foundation

struct FlightTrip: Identifiable, Codable {
    let id: String
    let flightNumber: String
    let routeName: String
    let departureTime: String
    let arrivalTime: String
}
