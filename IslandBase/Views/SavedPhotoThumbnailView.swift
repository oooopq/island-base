//
//  SavedPhotoThumbnailView.swift
//  Island Base
//
//  写真メモのグリッド用サムネイル（非同期読み込み）
//

import SwiftUI

struct SavedPhotoThumbnailView: View {
    let photo: IslandSavedPhoto
    let store: IslandSavedPhotoStore
    let height: CGFloat

    @Environment(\.detailPalette) private var palette
    @State private var image: UIImage?

    var body: some View {
        Group {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(height: height)
                    .clipped()
            } else {
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .fill(palette.chipBackground(isSelected: false))
                    .frame(height: height)
                    .overlay {
                        ProgressView()
                            .tint(palette.secondaryText)
                    }
            }
        }
        .task(id: photo.id) {
            image = await store.thumbnail(for: photo)
        }
    }
}
