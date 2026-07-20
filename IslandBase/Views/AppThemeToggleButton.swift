//
//  AppThemeToggleButton.swift
//  Island Base
//
//  ダーク / ライト切り替えボタン
//

import SwiftUI

struct AppThemeToggleButton: View {
    @Environment(AppThemeStore.self) private var themeStore
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        Button {
            themeStore.toggle()
        } label: {
            ThemeToggleIconView(
                systemImage: themeStore.mode.toggleSystemImage,
                palette: themeStore.palette
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(themeStore.mode.accessibilityLabel)
        .accessibilityHint(languageStore.t(.themeToggleHint))
    }
}
