//
//  IslandBackgroundView.swift
//  Island Base
//
//  島詳細画面の背景（海・花などの写真）
//

import SwiftUI

enum IslandHeroPhotoChrome {
    static let holdGradientTop = 0.0
    static let holdGradientBottom = 0.0
    static let afterZoomGradientTop = 0.10
    static let afterZoomGradientBottom = 0.50
    static let settledGradientTop = 0.18
    static let settledGradientBottom = 0.58
    static let readabilityBlurRadius: CGFloat = 10
    static let readabilityBlurDuration = 0.5
}

struct IslandBackgroundView: View {
    let islandID: String
    var photoScale: CGFloat = 1.0
    var zoomHeadroom: CGFloat = 1.0
    var blurRadius: CGFloat = IslandHeroPhotoChrome.readabilityBlurRadius
    var gradientTopOpacity: Double = IslandHeroPhotoChrome.settledGradientTop
    var gradientBottomOpacity: Double = IslandHeroPhotoChrome.settledGradientBottom

    private var backgroundAssetName: String {
        IslandCatalog.profile(for: islandID)?.backgroundAssetName ?? IslandCatalog.defaultBackgroundAssetName
    }

    var body: some View {
        IslandFullscreenPhotoView(
            assetName: backgroundAssetName,
            scale: photoScale,
            zoomHeadroom: zoomHeadroom
        )
        .blur(radius: blurRadius)
        .overlay {
            LinearGradient(
                colors: [
                    Color.black.opacity(gradientTopOpacity),
                    Color.black.opacity(gradientBottomOpacity),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            .allowsHitTesting(false)
        }
    }
}

#Preview {
    IslandBackgroundView(islandID: "ishigaki")
}
