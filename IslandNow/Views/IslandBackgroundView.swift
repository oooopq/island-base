//
//  IslandBackgroundView.swift
//  Island Now
//
//  島詳細画面の背景（海・花などの写真）
//

import SwiftUI

struct IslandBackgroundView: View {
    let islandID: String

    var body: some View {
        Image(IslandCatalog.profile(for: islandID)?.backgroundAssetName ?? IslandCatalog.defaultBackgroundAssetName)
            .resizable()
            .scaledToFill()
            .ignoresSafeArea()
            .overlay {
                LinearGradient(
                    colors: [
                        Color.black.opacity(0.10),
                        Color.black.opacity(0.50),
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            }
    }
}

#Preview {
    IslandBackgroundView(islandID: "ishigaki")
}
