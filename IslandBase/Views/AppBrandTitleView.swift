//
//  AppBrandTitleView.swift
//  Island Base
//
//  アプリアイコン（トップ画面ブランド表示）
//

import SwiftUI

struct AppBrandTitleView: View {
    enum Style {
        case hero
        case compact
        case splash
    }

    let style: Style

    private var iconSize: CGFloat {
        switch style {
        case .hero:
            return 48
        case .compact:
            return 28
        case .splash:
            return 108
        }
    }

    private var cornerRadius: CGFloat {
        switch style {
        case .hero:
            return 11
        case .compact:
            return 6
        case .splash:
            return 24
        }
    }

    var body: some View {
        Image("AppBrandIcon")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: iconSize, height: iconSize)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .accessibilityLabel("Island Base")
    }
}

#Preview("Hero Dark") {
    AppBrandTitleView(style: .hero)
        .padding()
        .background(Color.black)
        .environment(\.detailPalette, DetailCardPalette.dark)
        .preferredColorScheme(.dark)
}

#Preview("Hero Light") {
    AppBrandTitleView(style: .hero)
        .padding()
        .background(Color.white)
        .environment(\.detailPalette, DetailCardPalette.light)
        .preferredColorScheme(.light)
}

#Preview("Compact") {
    AppBrandTitleView(style: .compact)
        .padding()
        .background(Color.black)
        .environment(\.detailPalette, DetailCardPalette.dark)
}

#Preview("Splash") {
    AppBrandTitleView(style: .splash)
        .padding()
        .background(Color(red: 0.06, green: 0.08, blue: 0.12))
}
