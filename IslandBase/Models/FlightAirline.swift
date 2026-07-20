//
//  FlightAirline.swift
//  Island Base
//
//  航空会社の連絡先
//

import Foundation

struct FlightAirline: Codable {
    let name: String
    let websiteURL: String
    let phoneNumber: String
    /// 欠航・遅延の確認ページ（任意）
    let statusPageURL: String?

    init(
        name: String,
        websiteURL: String,
        phoneNumber: String,
        statusPageURL: String? = nil
    ) {
        self.name = name
        self.websiteURL = websiteURL
        self.phoneNumber = phoneNumber
        self.statusPageURL = statusPageURL
    }

    var phoneURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard digits.isEmpty == false else { return nil }
        return URL(string: "tel:\(digits)")
    }

    var websiteLink: URL? {
        AppURL.from(string: websiteURL)
    }

    var statusPageLink: URL? {
        AppURL.from(string: statusPageURL)
    }
}
