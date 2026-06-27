//
//  AppThemeStore.swift
//  Island Now
//
//  外観モードの保存と切り替え
//

import SwiftUI

@Observable
final class AppThemeStore {
    private static let storageKey = "appThemeMode"
    // v2: 説明UIをシートに変更したためキーを更新（以前の記録と区別）
    private static let hintShownKey = "appThemeToggleHintShown_v2"

    var mode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.storageKey)
        }
    }

    var palette: DetailCardPalette { mode.palette }
    var colorScheme: ColorScheme { mode.colorScheme }

    /// 初回起動時だけ、切り替えボタンの説明を表示する
    var shouldShowThemeHint: Bool {
        UserDefaults.standard.bool(forKey: Self.hintShownKey) == false
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = AppThemeMode(rawValue: raw) {
            mode = saved
        } else {
            mode = .dark
        }
    }

    func toggle() {
        mode = mode == .dark ? .light : .dark
    }

    func markThemeHintShown() {
        UserDefaults.standard.set(true, forKey: Self.hintShownKey)
    }

    #if DEBUG
    /// 開発中に初回シートを再表示したいとき用（App Store ビルドでは使わない）
    func resetThemeHintForTesting() {
        UserDefaults.standard.removeObject(forKey: Self.hintShownKey)
    }
    #endif
}
