//
//  AppBrandTitleView.swift
//  Island Now
//
//  アプリ名のワードマーク
//

import SwiftUI

struct AppBrandTitleView: View {
    enum Style {
        case hero
        case compact
    }

    let style: Style

    @Environment(\.detailPalette) private var palette

    var body: some View {
        switch style {
        case .hero:
            heroTitle
        case .compact:
            compactTitle
        }
    }

    private var heroTitle: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("Island")
                .font(.system(size: 36, weight: .ultraLight, design: .serif))
                .foregroundStyle(palette.text)

            Text("Now")
                .font(.system(size: 36, weight: .bold, design: .serif))
                .foregroundStyle(brandGradient)
        }
    }

    private var compactTitle: some View {
        HStack(alignment: .firstTextBaseline, spacing: 0) {
            Text("Island")
                .font(.system(size: 17, weight: .light, design: .serif))
                .foregroundStyle(palette.text)

            Text("Now")
                .font(.system(size: 17, weight: .bold, design: .serif))
                .foregroundStyle(brandGradient)
        }
    }

    private var brandGradient: LinearGradient {
        LinearGradient(
            colors: [palette.accent, palette.iconAccent],
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview("Hero") {
    AppBrandTitleView(style: .hero)
        .padding()
        .background(Color.black)
        .environment(\.detailPalette, DetailCardPalette.dark)
}

#Preview("Compact") {
    AppBrandTitleView(style: .compact)
        .padding()
        .background(Color.black)
        .environment(\.detailPalette, DetailCardPalette.dark)
}
