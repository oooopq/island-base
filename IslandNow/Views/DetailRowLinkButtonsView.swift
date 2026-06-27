//
//  DetailRowLinkButtonsView.swift
//  Island Now
//
//  詳細画面の行右端：Webサイト・ナビボタン
//

import SwiftUI

struct DetailRowLinkButtonsView: View {
    let websiteURL: URL?
    let onNavigate: (() -> Void)?

    @Environment(\.detailPalette) private var palette

    var body: some View {
        HStack(spacing: 8) {
            linkButton(
                url: websiteURL,
                systemImage: "globe",
                accessibilityLabel: "Webサイト",
                isEnabled: websiteURL != nil
            )

            navigateButton
        }
    }

    @ViewBuilder
    private var navigateButton: some View {
        if let onNavigate {
            Button(action: onNavigate) {
                linkButtonLabel(systemImage: "location.fill", isEnabled: true)
            }
            .buttonStyle(.plain)
            .accessibilityLabel("ナビ")
        } else {
            linkButtonLabel(systemImage: "location.fill", isEnabled: false)
                .accessibilityLabel("ナビ（利用不可）")
        }
    }

    @ViewBuilder
    private func linkButton(
        url: URL?,
        systemImage: String,
        accessibilityLabel: String,
        isEnabled: Bool
    ) -> some View {
        if isEnabled, let url {
            OpenURLButton(url: url) {
                linkButtonLabel(systemImage: systemImage, isEnabled: true)
            }
            .accessibilityLabel(accessibilityLabel)
        } else {
            linkButtonLabel(systemImage: systemImage, isEnabled: false)
                .accessibilityLabel("\(accessibilityLabel)（利用不可）")
        }
    }

    private func linkButtonLabel(systemImage: String, isEnabled: Bool) -> some View {
        Image(systemName: systemImage)
            .font(.subheadline)
            .frame(width: 34, height: 34)
            .foregroundStyle(isEnabled ? palette.accent : palette.secondaryText.opacity(0.45))
            .background(
                (isEnabled ? palette.accent.opacity(0.16) : palette.secondaryText.opacity(0.08)),
                in: Circle()
            )
    }
}
