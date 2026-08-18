//
//  PopToHomeToolbarButton.swift
//  Island Base
//
//  トップ画面（日本地図）へ戻るツールバーボタン
//

import SwiftUI

struct PopToHomeToolbarButton: View {
    @Environment(\.popToHome) private var popToHome
    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        Button {
            popToHome()
        } label: {
            ThemeToggleIconView(systemImage: "house", palette: palette)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(languageStore.t(.returnToIslandBase))
    }
}
