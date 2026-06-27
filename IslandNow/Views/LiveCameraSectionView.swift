//
//  LiveCameraSectionView.swift
//  Island Now
//
//  詳細画面のライブカメラセクション
//

import SwiftUI

struct LiveCameraSectionView: View {
    let cameras: [LiveCamera]
    let footnote: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("ライブカメラ")
                .font(.headline)

            if cameras.isEmpty {
                Text("この島のライブカメラ情報は準備中です")
                    .font(.subheadline)
                    .detailCardSecondaryText()
            } else {
                ForEach(Array(cameras.enumerated()), id: \.element.id) { index, camera in
                    if index > 0 {
                        Divider()
                    }
                    cameraRow(camera)
                }
            }

            Text(footnoteText)
                .font(.caption)
                .detailCardSecondaryText()
        }
        .detailSectionCard()
    }

    private var footnoteText: String {
        footnote ?? "※ 配信停止・メンテナンス中の場合があります。"
    }

    @ViewBuilder
    private func cameraRow(_ camera: LiveCamera) -> some View {
        if let url = URL(string: camera.urlString) {
            Link(destination: url) {
                HStack {
                    Image(systemName: "video.fill")
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

#Preview {
    LiveCameraSectionView(
        cameras: IslandCatalog.profile(for: "ishigaki")?.liveCameras ?? [],
        footnote: nil
    )
    .padding()
}
