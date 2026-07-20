//
//  OpenURLButton.swift
//  Island Base
//
//  Safari / 電話アプリなど外部リンクを確実に開く
//

import SwiftUI

struct OpenURLButton<Label: View>: View {
    let url: URL
    @ViewBuilder var label: () -> Label

    @Environment(\.openURL) private var openURL

    var body: some View {
        Button {
            openURL(url)
        } label: {
            label()
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
