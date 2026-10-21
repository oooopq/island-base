//
//  FlightAirline.swift
//  Island Base
//
//  航空会社の連絡先
//

import Foundation

struct FlightAirline: Codable {
    let name: String
    /// 公式英語名。nil のときは日本語名を出す。
    let nameEnglish: String?
    let websiteURL: String
    let phoneNumber: String
    /// 欠航・遅延の確認ページ（任意）
    let statusPageURL: String?

    init(
        name: String,
        nameEnglish: String? = nil,
        websiteURL: String,
        phoneNumber: String,
        statusPageURL: String? = nil
    ) {
        self.name = name
        self.nameEnglish = nameEnglish
        self.websiteURL = websiteURL
        self.phoneNumber = phoneNumber
        self.statusPageURL = statusPageURL
    }

    func displayName(for language: AppLanguageMode) -> String {
        if language == .english, let nameEnglish, nameEnglish.isEmpty == false {
            return nameEnglish
        }
        return name
    }

    private enum CodingKeys: String, CodingKey {
        case name
        case nameEnglish
        case websiteURL
        case phoneNumber
        case statusPageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        nameEnglish = try container.decodeIfPresent(String.self, forKey: .nameEnglish)
        websiteURL = try container.decode(String.self, forKey: .websiteURL)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        statusPageURL = try container.decodeIfPresent(String.self, forKey: .statusPageURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(nameEnglish, forKey: .nameEnglish)
        try container.encode(websiteURL, forKey: .websiteURL)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(statusPageURL, forKey: .statusPageURL)
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
