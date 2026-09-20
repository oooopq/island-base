//
//  AppLanguageMode.swift
//  Island Base
//
//  アプリ表示言語（日本語 / 英語）
//

import Foundation

enum AppLanguageMode: String, CaseIterable {
    case japanese = "ja"
    case english = "en"

    var isJapanese: Bool { self == .japanese }

    /// アプリ内の日付表示にも使う固定ロケール
    var locale: Locale {
        switch self {
        case .japanese: return Locale(identifier: "ja_JP")
        case .english: return Locale(identifier: "en_US")
        }
    }

    /// 切り替え後に表示する言語の短いラベル（ボタン用）
    var toggleButtonLabel: String {
        switch self {
        case .japanese: return "EN"
        case .english: return "JP"
        }
    }

    var accessibilityLabel: String {
        switch self {
        case .japanese: return "Switch to English"
        case .english: return "日本語に切り替え"
        }
    }
}
