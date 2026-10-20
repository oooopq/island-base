//
//  AppThemeMode.swift
//  Island Base
//
//  アプリ全体の外観（ダーク / ライト）
//

import SwiftUI

enum AppThemeMode: String, CaseIterable {
    case dark
    case light

    var colorScheme: ColorScheme {
        switch self {
        case .dark: return .dark
        case .light: return .light
        }
    }

    var palette: DetailCardPalette {
        switch self {
        case .dark: return .dark
        case .light: return .light
        }
    }

    var toggleSystemImage: String {
        switch self {
        case .dark: return "sun.max.fill"
        case .light: return "moon.fill"
        }
    }

    /// VoiceOver は AppText 経由（日本語モードの文言は従来と同じ）
    var accessibilityText: AppText {
        switch self {
        case .dark: return .switchToLightMode
        case .light: return .switchToDarkMode
        }
    }
}
