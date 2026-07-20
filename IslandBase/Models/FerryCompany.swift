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
        case .home: return "トップ"
        case .schedule: return "ダイヤ"
        case .status: return "運行状況"
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

struct FerryLinkButton: Identifiable {
    let id: String
    let kind: FerryLinkKind
    let url: URL
}

struct FerryCompany: Codable {
    let name: String
    /// 時刻表・予約ページ
    let websiteURL: String
    let phoneNumber: String
    /// 欠航・遅延の確認ページ（任意）
    let statusPageURL: String?
    /// 会社トップページ（任意。未設定ならトップボタンは出さない）
    let homePageURL: String?

    init(
        name: String,
        websiteURL: String,
        phoneNumber: String,
        statusPageURL: String? = nil,
        homePageURL: String? = nil
    ) {
        self.name = name
        self.websiteURL = websiteURL
        self.phoneNumber = phoneNumber
        self.statusPageURL = statusPageURL
        self.homePageURL = homePageURL
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

    /// 重複URLを除いた公式リンク（トップ・ダイヤ・運行状況）
    var linkButtons: [FerryLinkButton] {
        var buttons: [FerryLinkButton] = []
        var seenURLs = Set<String>()

        func append(kind: FerryLinkKind, urlString: String?) {
            guard let urlString, let url = AppURL.from(string: urlString) else { return }
            let key = url.absoluteString.lowercased()
            guard seenURLs.insert(key).inserted else { return }
            buttons.append(FerryLinkButton(id: key, kind: kind, url: url))
        }

        append(kind: .home, urlString: homePageURL)
        append(kind: .schedule, urlString: websiteURL)
        append(kind: .status, urlString: statusPageURL)

        return buttons
    }
}
