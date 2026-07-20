//
//  DetailSectionCardStyle.swift
//  Island Base
//
//  背景写真の上でも読みやすいカードスタイル
//

import SwiftUI

struct DetailSectionCardStyle: ViewModifier {
    @Environment(\.detailPalette) private var palette
    @Environment(AppThemeStore.self) private var themeStore

    func body(content: Content) -> some View {
        content
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(palette.text)
            .tint(palette.accent)
            .colorScheme(themeStore.colorScheme)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(palette.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(palette.cardBorder, lineWidth: 1)
                    }
                    .shadow(color: palette.cardShadow, radius: 8, y: 4)
            }
    }
}

extension View {
    func detailSectionCard() -> some View {
        modifier(DetailSectionCardStyle())
    }

    /// カード内の補助テキスト用
    func detailCardSecondaryText() -> some View {
        modifier(DetailCardSecondaryTextModifier())
    }
}

private struct DetailCardSecondaryTextModifier: ViewModifier {
    @Environment(\.detailPalette) private var palette

    func body(content: Content) -> some View {
        content.foregroundStyle(palette.secondaryText)
    }
}
