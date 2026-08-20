//
//  IslandFullscreenPhotoView.swift
//  Island Base
//
//  画面サイズに収めたフルスクリーン島写真（表示ピクセルへダウンサンプルする）
//

import SwiftUI
import UIKit

struct IslandFullscreenPhotoView: View {
    let assetName: String
    /// 入場演出などで拡大する場合に指定（画面枠の内側でクリップする）
    var scale: CGFloat = 1.0
    /// ダウンサンプル時のズーム余裕。アニメーションする scale とは別に固定する
    var zoomHeadroom: CGFloat = 1.0

    @Environment(\.displayScale) private var displayScale
    @State private var preparedImage: UIImage?

    var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            ZStack {
                Color.black

                if let image = displayedImage(for: size) {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size.width, height: size.height)
                        .scaleEffect(scale)
                        .clipped()
                }
            }
            .task(id: downsampleTaskID(for: size)) {
                guard size.width > 1, size.height > 1 else { return }
                preparedImage = await IslandPhotoDownsampler.image(
                    named: assetName,
                    filling: size,
                    displayScale: displayScale,
                    zoomHeadroom: max(zoomHeadroom, 1)
                )
            }
        }
        .onChange(of: assetName) { _, _ in
            preparedImage = nil
        }
        .ignoresSafeArea()
    }

    private func displayedImage(for size: CGSize) -> UIImage? {
        if let preparedImage {
            return preparedImage
        }
        return IslandPhotoDownsampler.cached(
            named: assetName,
            filling: size,
            displayScale: displayScale,
            zoomHeadroom: max(zoomHeadroom, 1)
        )
    }

    private func downsampleTaskID(for size: CGSize) -> String {
        let headroom = max(zoomHeadroom, 1)
        let pixelWidth = Int((size.width * displayScale * headroom).rounded())
        let pixelHeight = Int((size.height * displayScale * headroom).rounded())
        return "\(assetName)-\(pixelWidth)x\(pixelHeight)"
    }
}

#Preview {
    IslandFullscreenPhotoView(assetName: "IslandBgInujima", zoomHeadroom: 1.4)
}
