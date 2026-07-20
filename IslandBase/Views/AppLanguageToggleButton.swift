//
//  AppLanguageToggleButton.swift
//  Island Base
//
//  日本語 / 英語の切り替えボタン
//

import SwiftUI

struct AppLanguageToggleButton: View {
    @Environment(AppLanguageStore.self) private var languageStore
    @Environment(\.detailPalette) private var palette

    var body: some View {
        Button {
            languageStore.toggle()
        } label: {
            Text(languageStore.mode.toggleButtonLabel)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundStyle(palette.accent)
                .frame(width: 36, height: 36)
                .background(palette.accent.opacity(0.16), in: Circle())
                .overlay {
                    Circle()
                        .strokeBorder(palette.accent.opacity(0.35), lineWidth: 1)
                }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(languageStore.mode.accessibilityLabel)
        .accessibilityHint(languageStore.t(.languageToggleHint))
    }
}
