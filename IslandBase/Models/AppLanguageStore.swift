//
//  AppLanguageStore.swift
//  Island Base
//
//  表示言語の保存と切り替え
//

import SwiftUI

@Observable
final class AppLanguageStore {
    private static let storageKey = "appLanguageMode"

    var mode: AppLanguageMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.storageKey)
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = AppLanguageMode(rawValue: raw) {
            mode = saved
        } else {
            mode = .japanese
        }
    }

    func toggle() {
        mode = mode == .japanese ? .english : .japanese
    }

    /// UI 共通文言を現在の言語で返す
    func t(_ key: AppText) -> String {
        key.string(for: mode)
    }
}
