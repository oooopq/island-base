//
//  AppThemeStore.swift
//  Island Base
//
//  外観モードの保存と切り替え
//

import SwiftUI

@Observable
final class AppThemeStore {
    private static let storageKey = "appThemeMode"
    /// 旧: テーマのみの初回説明
    private static let hintShownKeyV2 = "appThemeToggleHintShown_v2"
    /// 新: テーマ＋言語の初回説明
    private static let hintShownKeyV3 = "appToolbarToggleHintShown_v3"

    var mode: AppThemeMode {
        didSet {
            UserDefaults.standard.set(mode.rawValue, forKey: Self.storageKey)
        }
    }

    var palette: DetailCardPalette { mode.palette }
    var colorScheme: ColorScheme { mode.colorScheme }

    /// 真の初回だけ表示。v2 を見た既存ユーザーには出さない
    var shouldShowToolbarHint: Bool {
        if UserDefaults.standard.bool(forKey: Self.hintShownKeyV2) {
            return false
        }
        return UserDefaults.standard.bool(forKey: Self.hintShownKeyV3) == false
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let saved = AppThemeMode(rawValue: raw) {
            mode = saved
        } else {
            mode = .dark
        }

        // 既存ユーザーは v3 を済み扱いにして、次回以降の判定を単純にする
        if UserDefaults.standard.bool(forKey: Self.hintShownKeyV2),
           UserDefaults.standard.bool(forKey: Self.hintShownKeyV3) == false {
            UserDefaults.standard.set(true, forKey: Self.hintShownKeyV3)
        }
    }

    func toggle() {
        mode = mode == .dark ? .light : .dark
    }

    func markToolbarHintShown() {
        UserDefaults.standard.set(true, forKey: Self.hintShownKeyV3)
        UserDefaults.standard.set(true, forKey: Self.hintShownKeyV2)
    }

    #if DEBUG
    /// 開発中に初回シートを再表示したいとき用（App Store ビルドでは使わない）
    func resetToolbarHintForTesting() {
        UserDefaults.standard.removeObject(forKey: Self.hintShownKeyV2)
        UserDefaults.standard.removeObject(forKey: Self.hintShownKeyV3)
    }
    #endif
}
