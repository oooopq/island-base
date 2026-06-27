//
//  AppThemeToggleButton.swift
//  Island Now
//
//  ダーク / ライト切り替えボタン
//

import SwiftUI

struct AppThemeToggleButton: View {
    @Environment(AppThemeStore.self) private var themeStore

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
        .accessibilityHint("画面の明るさを切り替えます")
    }
}
