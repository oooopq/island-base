//
//  IslandDetailSection.swift
//  Island Base
//
//  島詳細画面で切り替えるセクション
//

import SwiftUI

enum IslandDetailSection: String, CaseIterable, Identifiable {
    case weather
    case schedule
    case places
    case savedPhotos

    var id: String { rawValue }

    var title: String {
        title(for: .japanese)
    }

    func title(for language: AppLanguageMode) -> String {
        switch self {
        case .weather:
            return AppText.weather.string(for: language)
        case .schedule:
            return AppText.schedule.string(for: language)
        case .places:
            return AppText.places.string(for: language)
        case .savedPhotos:
            return AppText.savedPhotos.string(for: language)
        }
    }

    var systemImage: String {
        switch self {
        case .weather:
            return "cloud.sun"
        case .schedule:
            return "calendar.badge.clock"
        case .places:
            return "storefront"
        case .savedPhotos:
            return "photo.on.rectangle"
        }
    }
}
