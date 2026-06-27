//
//  LiveCameraSectionView.swift
//  Island Now
//
//  詳細画面のカメラセクション（ライブカメラ優先、なければ YouTube 関連）
//

import SwiftUI

struct LiveCameraSectionView: View {
    let liveCameras: [LiveCamera]
    let youtubeRelatedLinks: [LiveCamera]
    let footnote: String?

    private var showsLiveCameras: Bool {
        liveCameras.isEmpty == false
    }

    private var displayedLinks: [LiveCamera] {
        showsLiveCameras ? liveCameras : youtubeRelatedLinks
    }

    private var sectionTitle: String {
        showsLiveCameras ? "ライブカメラ" : "YouTube"
    }

    private var rowIcon: String {
        showsLiveCameras ? "video.fill" : "play.rectangle.fill"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sectionTitle)
                .font(.headline)

            if displayedLinks.isEmpty {
                Text(emptyMessage)
                    .font(.subheadline)
                    .detailCardSecondaryText()
            } else {
                ForEach(Array(displayedLinks.enumerated()), id: \.element.id) { index, camera in
                    if index > 0 {
                        Divider()
                    }
                    cameraRow(camera)
                }
            }

            if showsLiveCameras, let footnoteText = footnote ?? defaultLiveFootnote {
                Text(footnoteText)
                    .font(.caption)
                    .detailCardSecondaryText()
            }
        }
        .detailSectionCard()
    }

    private var emptyMessage: String {
        showsLiveCameras
            ? "この島のライブカメラ情報は準備中です"
            : "この島の YouTube 関連リンクは準備中です"
    }

    private var defaultLiveFootnote: String? {
        "※ 配信停止・メンテナンス中の場合があります。"
    }

    @ViewBuilder
    private func cameraRow(_ camera: LiveCamera) -> some View {
        if let url = camera.linkURL {
            OpenURLButton(url: url) {
                HStack {
                    Image(systemName: rowIcon)
                    Text(camera.title)
                    Spacer()
                    Image(systemName: "arrow.up.right")
                }
                .font(.subheadline)
            }
        } else {
            Text(camera.title)
                .font(.subheadline)
                .detailCardSecondaryText()
        }
    }
}

#Preview("ライブカメラあり") {
    LiveCameraSectionView(
        liveCameras: IslandCatalog.profile(for: "ishigaki")?.liveCameras ?? [],
        youtubeRelatedLinks: IslandCatalog.profile(for: "ishigaki")?.youtubeRelatedLinks ?? [],
        footnote: nil
    )
    .padding()
}

#Preview("YouTube フォールバック") {
    LiveCameraSectionView(
        liveCameras: [],
        youtubeRelatedLinks: IslandCatalog.profile(for: "taketomi")?.youtubeRelatedLinks ?? [],
        footnote: nil
    )
    .padding()
}
