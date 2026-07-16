//
//  ThemeToggleHintView.swift
//  Island Now
//
//  初回起動時：右上の外観・言語切り替えの説明（日本語固定）
//

import SwiftUI

struct ThemeToggleHintView: View {
    let mode: AppThemeMode
    let palette: DetailCardPalette

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("画面右上のボタン")
                .font(.headline)

            HStack(spacing: 28) {
                // 実ツールバーと同じ順：言語 → 明るさ（右端が明るさ）
                hintItem(
                    title: "言語",
                    detail: "日本語 / English"
                ) {
                    Text("EN")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(palette.accent)
                        .frame(width: 52, height: 52)
                        .background(palette.accent.opacity(0.16), in: Circle())
                        .overlay {
                            Circle()
                                .strokeBorder(palette.accent.opacity(0.35), lineWidth: 1)
                        }
                }

                hintItem(
                    title: "明るさ",
                    detail: "ライト / ダーク"
                ) {
                    ThemeToggleIconView(
                        systemImage: mode.toggleSystemImage,
                        palette: palette,
                        size: 52
                    )
                }
            }

            VStack(spacing: 8) {
                Text("見た目と言葉を切り替えられます")
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text("いつでも右上から切り替えられます。")
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }
            .multilineTextAlignment(.center)

            Button {
                dismiss()
            } label: {
                Text("OK")
                    .font(.headline)
                    .foregroundStyle(palette.accent)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(palette.accent.opacity(0.18), in: RoundedRectangle(cornerRadius: 12))
                    .contentShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.top, 4)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(palette.cardBackground)
    }

    private func hintItem<Icon: View>(
        title: String,
        detail: String,
        @ViewBuilder icon: () -> Icon
    ) -> some View {
        VStack(spacing: 10) {
            icon()

            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)

            Text(detail)
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
    }
}

#Preview {
    ThemeToggleHintView(mode: .dark, palette: .dark)
}
