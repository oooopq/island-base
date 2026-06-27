//
//  FlightAirline.swift
//  Island Now
//
//  航空会社の連絡先
//

import Foundation

struct FlightAirline: Codable {
    let name: String
    let websiteURL: String
    let phoneNumber: String

    var phoneURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard digits.isEmpty == false else { return nil }
        return URL(string: "tel:\(digits)")
    }

    var websiteLink: URL? {
        AppURL.from(string: websiteURL)
    }
}
