//
//  FetchRetryButton.swift
//  Island Base
//
//  天気・船便・店舗の取得失敗から、もう一度取り直す
//

import SwiftUI

struct FetchRetryButton: View {
    let action: () -> Void

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        Button(action: action) {
            Label(languageStore.t(.retryFetch), systemImage: "arrow.clockwise")
                .font(.subheadline.weight(.semibold))
        }
        .buttonStyle(.bordered)
        .tint(palette.accent)
    }
}
