//
//  FerryTrip.swift
//  Island Base
//
//  フェリー1便分の情報
//

import Foundation

struct FerryTrip: Identifiable, Codable {
    let id: String
    let routeName: String
    let departureTime: String
    let arrivalTime: String
}
