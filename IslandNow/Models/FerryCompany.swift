//
//  FerryCompany.swift
//  Island Now
//
//  フェリー運営会社の連絡先
//

import Foundation

struct FerryCompany: Codable {
    let name: String
    let websiteURL: String
    let phoneNumber: String

    // 電話アプリを開くためのURL
    var phoneURL: URL? {
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard digits.isEmpty == false else { return nil }
        return URL(string: "tel:\(digits)")
    }

    var websiteLink: URL? {
        AppURL.from(string: websiteURL)
    }
}
