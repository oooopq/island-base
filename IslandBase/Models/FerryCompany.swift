//
//  FerryCompany.swift
//  Island Base
//
//  フェリー運営会社の連絡先
//

import Foundation

/// 公式サイトへのリンク種別（最大3ボタン）
enum FerryLinkKind: String, CaseIterable {
    case home
    case schedule
    case status

    var titleJapanese: String {
        switch self {
        case .home: return "公式サイト"
        case .schedule: return "時刻表"
        case .status: return "運航状況"
        }
    }

    var titleEnglish: String {
        switch self {
        case .home: return "Official Site"
        case .schedule: return "Timetable"
        case .status: return "Service Status"
        }
    }

    func title(for language: AppLanguageMode) -> String {
        language.isJapanese ? titleJapanese : titleEnglish
    }

    var systemImage: String {
        switch self {
        case .home: return "house.fill"
        case .schedule: return "calendar"
        case .status: return "exclamationmark.triangle.fill"
        }
    }
}

struct FerryCompany: Codable {
    let name: String
    /// 公式英語名。nil のときは日本語名を出す。
    let nameEnglish: String?
    /// 時刻表・予約ページ
    let websiteURL: String
    let phoneNumber: String
    /// 欠航・遅延の確認ページ（任意）
    let statusPageURL: String?
    /// 会社トップページ（任意。未設定ならトップボタンは出さない）
    let homePageURL: String?

    init(
        name: String,
        nameEnglish: String? = nil,
        websiteURL: String,
        phoneNumber: String,
        statusPageURL: String? = nil,
        homePageURL: String? = nil
    ) {
        self.name = name
        self.nameEnglish = nameEnglish
        self.websiteURL = websiteURL
        self.phoneNumber = phoneNumber
        self.statusPageURL = statusPageURL
        self.homePageURL = homePageURL
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
        case homePageURL
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        nameEnglish = try container.decodeIfPresent(String.self, forKey: .nameEnglish)
        websiteURL = try container.decode(String.self, forKey: .websiteURL)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        statusPageURL = try container.decodeIfPresent(String.self, forKey: .statusPageURL)
        homePageURL = try container.decodeIfPresent(String.self, forKey: .homePageURL)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(nameEnglish, forKey: .nameEnglish)
        try container.encode(websiteURL, forKey: .websiteURL)
        try container.encode(phoneNumber, forKey: .phoneNumber)
        try container.encodeIfPresent(statusPageURL, forKey: .statusPageURL)
        try container.encodeIfPresent(homePageURL, forKey: .homePageURL)
    }

    // 電話アプリを開くためのURL
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

    var homePageLink: URL? {
        AppURL.from(string: homePageURL)
    }
}
