//
//  UsefulInfo.swift
//  Island Base
//
//  島のお役立ち情報（病院・ATM・観光案内など）
//

import Foundation

enum UsefulInfoCategory: String, CaseIterable, Identifiable {
    case medical = "病院・診療"
    case convenience = "コンビニ・ATM"
    case tourism = "観光・案内"

    var id: String { rawValue }

    func title(for language: AppLanguageMode) -> String {
        switch (self, language) {
        case (.medical, .japanese): return "病院・診療"
        case (.medical, .english): return "Medical"
        case (.convenience, .japanese): return "コンビニ・ATM"
        case (.convenience, .english): return "Convenience / ATM"
        case (.tourism, .japanese): return "観光・案内"
        case (.tourism, .english): return "Tourism"
        }
    }

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

    var canOpenNavigation: Bool {
        guard let address else { return false }
        return address.isEmpty == false
    }

    // Apple マップで車での案内を開く（住所から検索）
    func openDrivingDirections() {
        guard let address, address.isEmpty == false else { return }
        Task {
            await AppleMapsNavigation.openDrivingDirections(name: name, address: address)
        }
    }
}
