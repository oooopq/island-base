//
//  IslandBackgroundView.swift
//  Island Now
//
//  島詳細画面の背景（海・花などの写真）
//

import SwiftUI

struct IslandBackgroundView: View {
    let islandID: String
    /// 入場演出後は true にして、天気・ダイヤを読みやすくぼかす
    var blurForReadability: Bool = false

    private let readabilityBlurRadius: CGFloat = 10

    var body: some View {
        Image(IslandCatalog.profile(for: islandID)?.backgroundAssetName ?? IslandCatalog.defaultBackgroundAssetName)
            .resizable()
            .scaledToFill()
            .blur(radius: blurForReadability ? readabilityBlurRadius : 0)
            .ignoresSafeArea()
            .overlay {
                LinearGradient(
                    colors: blurForReadability
                        ? [
                            Color.black.opacity(0.18),
                            Color.black.opacity(0.58),
                        ]
                        : [
                            Color.black.opacity(0.10),
                            Color.black.opacity(0.50),
                        ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
            .animation(.easeInOut(duration: 0.5), value: blurForReadability)
    }
}

#Preview {
    IslandBackgroundView(islandID: "ishigaki")
}
