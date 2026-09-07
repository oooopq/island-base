//
//  RegionIslandsView.swift
//  Island Base
//
//  諸島郡内の島一覧（地域マップ＋リスト）
//

import MapKit
import SwiftUI
import UIKit

struct RegionIslandsView: View {
    let region: IslandRegion

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
    @State private var cameraPosition: MapCameraPosition = .automatic

    private var islands: [Island] {
        IslandCatalog.islands(forRegionID: region.id)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                regionMap

                VStack(spacing: 10) {
                    ForEach(islands) { island in
                        NavigationLink(value: island) {
                            IslandRowView(island: island)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(listBackground)
        .navigationTitle(region.displayName(for: languageStore.mode))
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Island.self) { island in
            IslandDetailView(island: island)
        }
        .onAppear {
            cameraPosition = RegionMapSupport.cameraPosition(for: islands)
        }
    }

    private var regionMap: some View {
        Map(position: $cameraPosition, interactionModes: [.pan, .zoom]) {
            ForEach(islands) { island in
                Annotation(island.primaryName(for: languageStore.mode), coordinate: island.coordinate) {
                    Image(systemName: "mountain.2.fill")
                        .font(.caption)
                        .padding(6)
                        .background(Circle().fill(palette.iconAccent.opacity(0.9)))
                        .foregroundStyle(.white)
                }
            }
        }
        .mapStyle(.standard(elevation: .flat))
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
        .allowsHitTesting(false)
    }

    private var listBackground: some View {
        palette.cardBackground.opacity(0.15)
            .ignoresSafeArea()
    }
}

private struct IslandRowView: View {
    let island: Island

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private var backgroundAssetName: String {
        IslandCatalog.profile(for: island)?.backgroundAssetName ?? IslandCatalog.defaultBackgroundAssetName
    }

    var body: some View {
        HStack(spacing: 14) {
            IslandListThumbnailView(assetName: backgroundAssetName)

            VStack(alignment: .leading, spacing: 4) {
                Text(island.primaryName(for: languageStore.mode))
                    .font(.headline)
                    .foregroundStyle(palette.text)

                Text(island.secondaryName(for: languageStore.mode).uppercased())
                    .font(.caption)
                    .tracking(1.2)
                    .foregroundStyle(palette.secondaryText)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(palette.secondaryText)
        }
        .padding(12)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(palette.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(palette.cardBorder, lineWidth: 1)
                }
        }
    }
}

/// 一覧サムネイルは表示ピクセルへ先に縮小する（フル解像度の GPU 縮小で瓦屋根などがチラつくのを避ける）
private struct IslandListThumbnailView: View {
    let assetName: String

    @Environment(\.displayScale) private var displayScale
    @State private var preparedImage: UIImage?

    var body: some View {
        ZStack {
            if let image = displayedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            }
        }
        .frame(width: IslandListThumbnailCache.pointSize, height: IslandListThumbnailCache.pointSize)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        .task(id: taskID) {
            preparedImage = await IslandListThumbnailCache.image(
                named: assetName,
                displayScale: displayScale
            )
        }
        .onChange(of: assetName) { _, _ in
            preparedImage = nil
        }
    }

    private var displayedImage: UIImage? {
        if let preparedImage {
            return preparedImage
        }
        return IslandListThumbnailCache.cached(named: assetName, displayScale: displayScale)
    }

    private var taskID: String {
        IslandListThumbnailCache.cacheKey(assetName: assetName, displayScale: displayScale) as String
    }
}

private enum IslandListThumbnailCache {
    static let pointSize: CGFloat = 64

    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 48
        cache.totalCostLimit = 8 * 1024 * 1024
        return cache
    }()

    static func cached(named assetName: String, displayScale: CGFloat) -> UIImage? {
        cache.object(forKey: cacheKey(assetName: assetName, displayScale: displayScale))
    }

    static func image(named assetName: String, displayScale: CGFloat) async -> UIImage? {
        let key = cacheKey(assetName: assetName, displayScale: displayScale)
        if let cached = cache.object(forKey: key) {
            return cached
        }

        let source = await MainActor.run { UIImage(named: assetName) }
        guard let source else { return nil }

        let thumbnailSize = coverThumbnailSize(for: source, displayScale: displayScale)
        let thumbnail = await Task.detached(priority: .userInitiated) {
            source.preparingThumbnail(of: thumbnailSize)
        }.value
        guard let thumbnail else { return nil }

        cache.setObject(
            thumbnail,
            forKey: key,
            cost: Int(thumbnail.size.width * thumbnail.size.height * thumbnail.scale * thumbnail.scale * 4)
        )
        return thumbnail
    }

    static func cacheKey(assetName: String, displayScale: CGFloat) -> NSString {
        "\(assetName)-\(pixelSize(displayScale: displayScale))" as NSString
    }

    private static func pixelSize(displayScale: CGFloat) -> Int {
        max(Int((pointSize * max(displayScale, 1)).rounded()), 1)
    }

    /// `preparingThumbnail` は指定サイズに内接させる。正方形へ aspect-fill したとき短辺が欠けない大きさにする。
    private static func coverThumbnailSize(for image: UIImage, displayScale: CGFloat) -> CGSize {
        let pixel = CGFloat(pixelSize(displayScale: displayScale))
        let sourcePixels = CGSize(
            width: max(image.size.width * image.scale, 1),
            height: max(image.size.height * image.scale, 1)
        )
        let shortSide = min(sourcePixels.width, sourcePixels.height)
        let requestedPixels = pixel * max(sourcePixels.width, sourcePixels.height) / shortSide
        let requestedPoints = requestedPixels / max(image.scale, 1)
        return CGSize(width: requestedPoints, height: requestedPoints)
    }
}

#Preview {
    NavigationStack {
        RegionIslandsView(region: IslandRegionCatalog.yaeyama)
    }
    .environment(AppThemeStore())
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
