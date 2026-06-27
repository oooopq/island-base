//
//  ThemeToggleHintView.swift
//  Island Now
//
//  初回起動時：外観切り替えボタンの説明
//

import SwiftUI

struct ThemeToggleHintView: View {
    let mode: AppThemeMode
    let palette: DetailCardPalette

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("画面の明るさを切り替え")
                .font(.headline)

            ThemeToggleIconView(
                systemImage: mode.toggleSystemImage,
                palette: palette,
                size: 56
            )

            VStack(spacing: 8) {
                Text("画面右上のこのボタン")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(mode.accessibilityLabel)
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryText)

                Text("いつでも切り替えられます。")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .multilineTextAlignment(.center)

            Button("OK") {
                dismiss()
            }
            .font(.headline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(palette.accent.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(palette.accent)
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.cardBackground)
    }
}

#Preview {
    ThemeToggleHintView(mode: .dark, palette: .dark)
}
