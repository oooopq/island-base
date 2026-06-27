//
//  UsefulInfo.swift
//  Island Now
//
//  島のお役立ち情報（病院・ATM・観光案内など）
//

import Foundation

enum UsefulInfoCategory: String, CaseIterable, Identifiable {
    case medical = "病院・診療"
    case convenience = "コンビニ・ATM"
    case tourism = "観光・案内"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .medical:
            return "cross.case.fill"
        case .convenience:
            return "creditcard.fill"
        case .tourism:
            return "info.circle.fill"
        }
    }
}

struct UsefulInfo: Identifiable, Hashable {
    let id: String
    let category: UsefulInfoCategory
    let name: String
    let phoneNumber: String?
    let address: String?
    let websiteURL: String?
    let note: String?

    var phoneURL: URL? {
        guard let phoneNumber else { return nil }
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard digits.isEmpty == false else { return nil }
        return URL(string: "tel:\(digits)")
    }

    var websiteLink: URL? {
        AppURL.from(string: websiteURL)
    }

    // 住所から Apple マップのナビ URL を作る
    var navigationURL: URL? {
        guard let address, address.isEmpty == false else { return nil }

        var components = URLComponents(string: "https://maps.apple.com/")
        components?.queryItems = [
            URLQueryItem(name: "daddr", value: address),
            URLQueryItem(name: "dirflg", value: "d"),
            URLQueryItem(name: "q", value: name),
        ]
        return components?.url
    }
}
