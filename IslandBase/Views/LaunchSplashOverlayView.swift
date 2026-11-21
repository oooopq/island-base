//
//  LaunchSplashOverlayView.swift
//  Island Base
//
//  コールドスタート直後のスプラッシュアニメーション
//

import SwiftUI

struct LaunchSplashOverlayView: View {
    let onFinished: () -> Void

    @Environment(\.detailPalette) private var palette
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var iconOpacity = 0.0
    @State private var iconScale: CGFloat = 0.78
    @State private var iconOffsetY: CGFloat = 20
    @State private var titleOpacity = 0.0
    @State private var titleOffsetY: CGFloat = 10
    @State private var overlayOpacity = 1.0

    var body: some View {
        ZStack {
            palette.background
                .ignoresSafeArea()

            VStack(spacing: 22) {
                AppBrandTitleView(style: .splash)
                    .shadow(color: palette.cardShadow, radius: 12, y: 6)
                    .scaleEffect(iconScale)
                    .offset(y: iconOffsetY)
                    .opacity(iconOpacity)

                Text("Island Base")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(palette.text)
                    .opacity(titleOpacity)
                    .offset(y: titleOffsetY)
            }
        }
        .opacity(overlayOpacity)
        .ignoresSafeArea()
        .accessibilityHidden(true)
        .task {
            await runSplash()
            onFinished()
        }
    }

    @MainActor
    private func runSplash() async {
        if reduceMotion {
            iconOpacity = 1
            iconScale = 1
            iconOffsetY = 0
            titleOpacity = 1
            titleOffsetY = 0
            try? await Task.sleep(for: .seconds(0.35))
            withAnimation(.easeOut(duration: 0.20)) {
                overlayOpacity = 0
            }
            try? await Task.sleep(for: .seconds(0.20))
            return
        }

        withAnimation(.spring(response: 0.62, dampingFraction: 0.78)) {
            iconOpacity = 1
            iconScale = 1
            iconOffsetY = 0
        }

        try? await Task.sleep(for: .seconds(0.28))

        withAnimation(.easeOut(duration: 0.36)) {
            titleOpacity = 1
            titleOffsetY = 0
        }

        try? await Task.sleep(for: .seconds(0.92))

        withAnimation(.easeIn(duration: 0.42)) {
            overlayOpacity = 0
            iconScale = 1.08
        }

        try? await Task.sleep(for: .seconds(0.42))
    }
}

#Preview {
    LaunchSplashOverlayView(onFinished: {})
        .environment(\.detailPalette, DetailCardPalette.dark)
}
