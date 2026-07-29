//
//  ThemeToggleHintView.swift
//  Island Base
//
//  初回起動時：右上の外観・言語切り替えの説明
//

import SwiftUI

struct ThemeToggleHintView: View {
    let mode: AppThemeMode
    let palette: DetailCardPalette

    @Environment(\.dismiss) private var dismiss
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(spacing: 20) {
            Text(languageStore.t(.toolbarHintTitle))
                .font(.headline)

            HStack(spacing: 28) {
                // 実ツールバーと同じ順：言語 → 明るさ（右端が明るさ）
                hintItem(
                    title: languageStore.t(.hintLanguageTitle),
                    detail: languageStore.t(.hintLanguageDetail)
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
                    title: languageStore.t(.hintBrightnessTitle),
                    detail: languageStore.t(.hintBrightnessDetail)
                ) {
                    ThemeToggleIconView(
                        systemImage: mode.toggleSystemImage,
                        palette: palette,
                        size: 52
                    )
                }
            }

            VStack(spacing: 8) {
                Text(languageStore.t(.hintAppearanceAndLanguage))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(languageStore.t(.hintAppearanceAndLanguageFooter))
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
        .environment(AppLanguageStore())
}
