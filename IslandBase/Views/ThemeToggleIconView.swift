//
//  ThemeToggleIconView.swift
//  Island Base
//
//  外観切り替えボタンのアイコン表示（ツールバーと説明で共通）
//

import SwiftUI

struct ThemeToggleIconView: View {
    let systemImage: String
    let palette: DetailCardPalette
    var size: CGFloat = 36

    var body: some View {
        Image(systemName: systemImage)
            .font(.body)
            .fontWeight(.semibold)
            .foregroundStyle(palette.accent)
            .frame(width: size, height: size)
            .background(palette.accent.opacity(0.16), in: Circle())
            .overlay {
                Circle()
                    .strokeBorder(palette.accent.opacity(0.35), lineWidth: 1)
            }
            .accessibilityHidden(true)
    }
}
