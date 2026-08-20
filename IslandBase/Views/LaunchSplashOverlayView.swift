//
//  LaunchSplashOverlayView.swift
//  Island Base
//
//  コールドスタート直後のスプラッシュアニメーション
//

import SwiftUI

struct LaunchSplashOverlayView: View {
    let onFinished: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var iconOpacity = 0.0
    @State private var iconScale: CGFloat = 0.78
    @State private var iconOffsetY: CGFloat = 20
    @State private var titleOpacity = 0.0
    @State private var titleOffsetY: CGFloat = 10
    @State private var overlayOpacity = 1.0

    var body: some View {
        ZStack {
            LaunchSplashPalette.background
                .ignoresSafeArea()

            VStack(spacing: 22) {
                ZStack {
                    Circle()
                        .fill(LaunchSplashPalette.glow.opacity(0.22))
                        .frame(width: 168, height: 168)
                        .blur(radius: 28)
                        .opacity(iconOpacity)

                    AppBrandTitleView(style: .splash)
                        .shadow(color: .black.opacity(0.30), radius: 16, y: 8)
                }
                .scaleEffect(iconScale)
                .offset(y: iconOffsetY)
                .opacity(iconOpacity)

                Text("Island Base")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(Color.white.opacity(0.92))
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

private enum LaunchSplashPalette {
    /// ホーム画面と同じネイビー。システム起動画面とも揃える
    static let background = Color(red: 0.06, green: 0.08, blue: 0.12)
    static let glow = Color(red: 0.25, green: 0.82, blue: 0.95)
}

#Preview {
    LaunchSplashOverlayView(onFinished: {})
}
