//
//  IslandPhotoDownsampler.swift
//  Island Base
//
//  フルスクリーン島写真を、画面ピクセルとズーム余裕に合わせて縮小する
//

import UIKit

enum IslandPhotoDownsampler {
    private static let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 12
        cache.totalCostLimit = 64 * 1024 * 1024
        return cache
    }()

    static func cached(
        named assetName: String,
        filling pointSize: CGSize,
        displayScale: CGFloat,
        zoomHeadroom: CGFloat
    ) -> UIImage? {
        cache.object(forKey: cacheKey(
            assetName: assetName,
            filling: pointSize,
            displayScale: displayScale,
            zoomHeadroom: zoomHeadroom
        ))
    }

    static func image(
        named assetName: String,
        filling pointSize: CGSize,
        displayScale: CGFloat,
        zoomHeadroom: CGFloat
    ) async -> UIImage? {
        let key = cacheKey(
            assetName: assetName,
            filling: pointSize,
            displayScale: displayScale,
            zoomHeadroom: zoomHeadroom
        )
        if let cached = cache.object(forKey: key) {
            return cached
        }

        guard pointSize.width > 1, pointSize.height > 1 else { return nil }

        let headroom = max(zoomHeadroom, 1)

        let source = await MainActor.run { UIImage(named: assetName) }
        guard let source else { return nil }

        let downsampled = await Task.detached(priority: .userInitiated) { () -> UIImage in
            downsample(
                source,
                filling: pointSize,
                displayScale: displayScale,
                zoomHeadroom: headroom
            )
        }.value

        cache.setObject(
            downsampled,
            forKey: key,
            cost: Int(downsampled.size.width * downsampled.size.height * downsampled.scale * downsampled.scale * 4)
        )
        return downsampled
    }

    private static func cacheKey(
        assetName: String,
        filling pointSize: CGSize,
        displayScale: CGFloat,
        zoomHeadroom: CGFloat
    ) -> NSString {
        let headroom = max(zoomHeadroom, 1)
        let pixelWidth = Int((pointSize.width * displayScale * headroom).rounded())
        let pixelHeight = Int((pointSize.height * displayScale * headroom).rounded())
        return "\(assetName)-\(pixelWidth)x\(pixelHeight)" as NSString
    }

    nonisolated private static func downsample(
        _ image: UIImage,
        filling pointSize: CGSize,
        displayScale: CGFloat,
        zoomHeadroom: CGFloat
    ) -> UIImage {
        let outputSize = outputPixelSize(
            image: image,
            filling: pointSize,
            displayScale: displayScale,
            zoomHeadroom: zoomHeadroom
        )

        let imagePixelSize = CGSize(
            width: max(image.size.width * image.scale, 1),
            height: max(image.size.height * image.scale, 1)
        )
        let coverScale = max(
            outputSize.width / imagePixelSize.width,
            outputSize.height / imagePixelSize.height
        )

        let source: UIImage
        if coverScale < 0.92 {
            let thumbnailSize = CGSize(
                width: image.size.width * coverScale,
                height: image.size.height * coverScale
            )
            source = image.preparingThumbnail(of: thumbnailSize) ?? image
        } else {
            source = image
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true
        let renderer = UIGraphicsImageRenderer(size: outputSize, format: format)
        return renderer.image { _ in
            let drawRect = aspectFillRect(for: source.size, in: outputSize)
            source.draw(in: drawRect)
        }
    }

    /// 要求ピクセルと元画像のクロップを比べ、拡大はしない
    nonisolated private static func outputPixelSize(
        image: UIImage,
        filling pointSize: CGSize,
        displayScale: CGFloat,
        zoomHeadroom: CGFloat
    ) -> CGSize {
        let requested = CGSize(
            width: max((pointSize.width * displayScale * zoomHeadroom).rounded(), 1),
            height: max((pointSize.height * displayScale * zoomHeadroom).rounded(), 1)
        )
        let imagePixels = CGSize(
            width: max(image.size.width * image.scale, 1),
            height: max(image.size.height * image.scale, 1)
        )
        let requestedAspect = requested.width / requested.height
        let imageAspect = imagePixels.width / imagePixels.height

        let crop: CGSize
        if imageAspect > requestedAspect {
            crop = CGSize(width: imagePixels.height * requestedAspect, height: imagePixels.height)
        } else {
            crop = CGSize(width: imagePixels.width, height: imagePixels.width / requestedAspect)
        }

        return CGSize(
            width: max(min(crop.width, requested.width).rounded(), 1),
            height: max(min(crop.height, requested.height).rounded(), 1)
        )
    }

    nonisolated private static func aspectFillRect(for imageSize: CGSize, in bounds: CGSize) -> CGRect {
        let width = max(imageSize.width, 1)
        let height = max(imageSize.height, 1)
        let fill = max(bounds.width / width, bounds.height / height)
        let drawSize = CGSize(width: width * fill, height: height * fill)
        return CGRect(
            x: (bounds.width - drawSize.width) / 2,
            y: (bounds.height - drawSize.height) / 2,
            width: drawSize.width,
            height: drawSize.height
        )
    }
}
