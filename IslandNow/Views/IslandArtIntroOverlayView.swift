//
//  IslandArtIntroOverlayView.swift
//  Island Now
//
//  島詳細を開いた直後のフルスクリーン写真 → ズームアウト演出
//

import SwiftUI

struct IslandArtIntroOverlayView: View {
    let assetName: String
    let artIntro: IslandArtIntro
    let onZoomOutStart: () -> Void
    let onFinished: () -> Void

    @State private var photoScale: CGFloat
    @State private var showsBackgroundGradient = false
    @State private var overlayOpacity = 1.0

    init(
        assetName: String,
        artIntro: IslandArtIntro,
        onZoomOutStart: @escaping () -> Void,
        onFinished: @escaping () -> Void
    ) {
        self.assetName = assetName
        self.artIntro = artIntro
        self.onZoomOutStart = onZoomOutStart
        self.onFinished = onFinished
        _photoScale = State(initialValue: artIntro.startScale)
    }

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            Image(assetName)
                .resizable()
                .scaledToFill()
                .scaleEffect(photoScale)
                .overlay {
                    if showsBackgroundGradient {
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.10),
                                Color.black.opacity(0.50),
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    }
                }
                .ignoresSafeArea()
        }
        .opacity(overlayOpacity)
        .ignoresSafeArea()
        .task {
            await runIntro()
        }
    }

    @MainActor
    private func runIntro() async {
        try? await Task.sleep(for: .seconds(artIntro.holdSeconds))

        onZoomOutStart()

        withAnimation(.easeInOut(duration: artIntro.zoomOutSeconds)) {
            photoScale = 1.0
            showsBackgroundGradient = true
        }

        try? await Task.sleep(for: .seconds(artIntro.zoomOutSeconds))

        withAnimation(.easeOut(duration: 0.2)) {
            overlayOpacity = 0
        }

        try? await Task.sleep(for: .seconds(0.2))
        onFinished()
    }
}

#Preview {
    IslandArtIntroOverlayView(
        assetName: "IslandBgInujima",
        artIntro: .fullscreenZoomOut,
        onZoomOutStart: {},
        onFinished: {}
    )
}
