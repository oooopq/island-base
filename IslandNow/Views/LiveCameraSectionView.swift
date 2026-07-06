//
//  LiveCameraSectionView.swift
//  Island Now
//
//  各島のライブカメラ・関連動画リンク
//

import SwiftUI

struct LiveCameraSectionView: View {
    let liveCameras: [LiveCamera]
    let relatedLinks: [LiveCamera]
    let footnote: String?

    @Environment(\.detailPalette) private var palette

    private var hasLinks: Bool {
        liveCameras.isEmpty == false || relatedLinks.isEmpty == false
    }

    var body: some View {
        if hasLinks {
            VStack(alignment: .leading, spacing: 14) {
                header

                cameraBlock(title: "ライブカメラ", items: liveCameras)
                cameraBlock(title: "関連リンク", items: relatedLinks)

                if let footnote, footnote.isEmpty == false {
                    Text(footnote)
                        .font(.caption)
                        .detailCardSecondaryText()
                }
            }
            .detailSectionCard()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Label("ライブカメラ・関連リンク", systemImage: "video.fill")
                .font(.headline)
                .foregroundStyle(palette.text)

            Text("公開配信や公式ページを外部ブラウザで開きます。")
                .font(.caption)
                .detailCardSecondaryText()
        }
    }

    @ViewBuilder
    private func cameraBlock(title: String, items: [LiveCamera]) -> some View {
        if items.isEmpty == false {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.accent)

                ForEach(items) { camera in
                    cameraRow(camera)
                }
            }
        }
    }

    private func cameraRow(_ camera: LiveCamera) -> some View {
        HStack(alignment: .center, spacing: 10) {
            Image(systemName: "play.rectangle.fill")
                .frame(width: 24)
                .foregroundStyle(palette.iconAccent)

            Text(camera.title)
                .font(.subheadline)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let url = camera.linkURL {
                OpenURLButton(url: url) {
                    Image(systemName: "arrow.up.right.square")
                        .font(.subheadline)
                        .frame(width: 34, height: 34)
                        .foregroundStyle(palette.accent)
                        .background(palette.accent.opacity(0.16), in: Circle())
                }
                .accessibilityLabel("\(camera.title)を開く")
            }
        }
    }
}

#Preview {
    LiveCameraSectionView(
        liveCameras: [
            LiveCamera(title: "石垣港ライブカメラ", urlString: "https://www.youtube.com/")
        ],
        relatedLinks: [
            LiveCamera(title: "観光協会の関連リンク", urlString: "https://example.com/")
        ],
        footnote: "※ 外部サイトの配信状況により表示されない場合があります。"
    )
    .padding()
    .environment(AppThemeStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
