//
//  DetailRowLinkButtonsView.swift
//  Island Base
//
//  詳細画面の行右端：Webサイト・ナビ・Google マップボタン
//

import SwiftUI

struct DetailRowLinkButtonsView: View {
    let websiteURL: URL?
    var googleMapsURL: URL? = nil
    let onNavigate: (() -> Void)?

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private let compactButtonSize: CGFloat = 30
    private let standardButtonSize: CGFloat = 34

    var body: some View {
        if googleMapsURL != nil {
            compactActionGrid
        } else {
            standardActionRow
        }
    }

    private var standardActionRow: some View {
        HStack(spacing: 8) {
            websiteButton(size: standardButtonSize)

            navigateButton(size: standardButtonSize)
        }
    }

    private var compactActionGrid: some View {
        VStack(spacing: 6) {
            HStack(spacing: 6) {
                websiteButton(size: compactButtonSize)
                googleMapsButton(size: compactButtonSize)
            }

            HStack(spacing: 6) {
                navigateButton(size: compactButtonSize)
                Color.clear
                    .frame(width: compactButtonSize, height: compactButtonSize)
                    .accessibilityHidden(true)
            }
        }
    }

    @ViewBuilder
    private func websiteButton(size: CGFloat) -> some View {
        linkButton(
            url: websiteURL,
            systemImage: "globe",
            accessibilityLabel: languageStore.t(.openWebsite),
            isEnabled: websiteURL != nil,
            size: size
        )
    }

    @ViewBuilder
    private func googleMapsButton(size: CGFloat) -> some View {
        linkButton(
            url: googleMapsURL,
            systemImage: "map",
            accessibilityLabel: languageStore.t(.openInGoogleMaps),
            isEnabled: googleMapsURL != nil,
            size: size
        )
    }

    @ViewBuilder
    private func navigateButton(size: CGFloat) -> some View {
        if let onNavigate {
            Button(action: onNavigate) {
                linkButtonLabel(systemImage: "location.fill", isEnabled: true, size: size)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(languageStore.t(.openNavigation))
        } else {
            linkButtonLabel(systemImage: "location.fill", isEnabled: false, size: size)
                .accessibilityLabel(languageStore.t(.openNavigationUnavailable))
        }
    }

    @ViewBuilder
    private func linkButton(
        url: URL?,
        systemImage: String,
        accessibilityLabel: String,
        isEnabled: Bool,
        size: CGFloat
    ) -> some View {
        if isEnabled, let url {
            OpenURLButton(url: url) {
                linkButtonLabel(systemImage: systemImage, isEnabled: true, size: size)
            }
            .accessibilityLabel(accessibilityLabel)
        } else {
            linkButtonLabel(systemImage: systemImage, isEnabled: false, size: size)
                .accessibilityLabel(accessibilityLabel)
        }
    }

    private func linkButtonLabel(systemImage: String, isEnabled: Bool, size: CGFloat) -> some View {
        Image(systemName: systemImage)
            .font(.subheadline)
            .frame(width: size, height: size)
            .foregroundStyle(isEnabled ? palette.accent : palette.secondaryText.opacity(0.45))
            .background(
                (isEnabled ? palette.accent.opacity(0.16) : palette.secondaryText.opacity(0.08)),
                in: Circle()
            )
    }
}
