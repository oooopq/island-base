//
//  JMAMarineForecastLinkView.swift
//  Island Base
//
//  気象庁「海上警報・予報」へのリンク（細分海域別）
//

import SwiftUI

struct JMAMarineForecastLinkView: View {
    let area: JMAMarineForecastArea

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        if let url = area.forecastURL(for: languageStore.mode) {
            VStack(alignment: .leading, spacing: 4) {
                OpenURLButton(url: url) {
                    Label {
                        Text(
                            languageStore.t(
                                .jmaMarineForecastLink(area.displayName(for: languageStore.mode))
                            )
                        )
                        .font(.caption.weight(.medium))
                        .foregroundStyle(palette.accent)
                        .multilineTextAlignment(.leading)
                    } icon: {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }

                Text(languageStore.t(.jmaMarineForecastNote))
                    .font(.caption2)
                    .foregroundStyle(palette.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}
