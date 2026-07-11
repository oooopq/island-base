//
//  IslandFullscreenPhotoView.swift
//  Island Now
//
//  画面サイズに収めたフルスクリーン島写真（超横長画像のテクスチャ暴走を防ぐ）
//

import SwiftUI

struct IslandFullscreenPhotoView: View {
    let assetName: String
    /// 入場演出などで拡大する場合に指定（画面枠の内側でクリップする）
    var scale: CGFloat = 1.0

    var body: some View {
        GeometryReader { geometry in
            Image(assetName)
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width, height: geometry.size.height)
                .scaleEffect(scale)
                .clipped()
        }
        .ignoresSafeArea()
    }
}

#Preview {
    IslandFullscreenPhotoView(assetName: "IslandBgInujima")
}
