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

    var accessibilityLabel: String {
        switch self {
        case .dark: return "ライトモードに切り替え"
        case .light: return "ダークモードに切り替え"
        }
    }
}
