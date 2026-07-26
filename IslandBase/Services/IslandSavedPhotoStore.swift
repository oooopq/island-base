//
//  IslandSavedPhotoStore.swift
//  Island Base
//
//  島ごとのダイヤ写真をアプリ内サンドボックスだけに保存する
//

import Foundation
import UIKit

@Observable
@MainActor
final class IslandSavedPhotoStore {
    /// 1島あたりの保存上限
    static let maxPhotosPerIsland = 20

    /// 本画像の長辺上限（ダイヤ文字が読める程度）
    private static let maxFullImageLongEdge: CGFloat = 1600
    /// グリッド用サムネイルの長辺上限
    private static let maxThumbnailLongEdge: CGFloat = 300
    private static let fullJPEGQuality: CGFloat = 0.80
    private static let thumbnailJPEGQuality: CGFloat = 0.75

    private(set) var photos: [IslandSavedPhoto] = []

    private let fileManager = FileManager.default
    private let thumbnailCache = NSCache<NSString, UIImage>()

    var canAddPhoto: Bool {
        photos.count < Self.maxPhotosPerIsland
    }

    private var storageRoot: URL {
        let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        return appSupport.appendingPathComponent("IslandSavedPhotos", isDirectory: true)
    }

    func loadPhotos(for islandID: String) {
        ensureStorageDirectoryExists()

        guard let data = try? Data(contentsOf: manifestURL(for: islandID)),
              let decoded = try? JSONDecoder().decode([IslandSavedPhoto].self, from: data) else {
            photos = []
            return
        }

        photos = decoded.sorted { $0.createdAt > $1.createdAt }
    }

    @discardableResult
    func addPhoto(_ image: UIImage, for islandID: String) -> Bool {
        guard canAddPhoto else { return false }

        ensureStorageDirectoryExists()

        let photoID = UUID().uuidString
        let fileName = "\(photoID).jpg"
        let thumbFileName = Self.thumbnailFileName(for: fileName)
        let fileURL = photoFileURL(islandID: islandID, fileName: fileName)
        let thumbURL = photoFileURL(islandID: islandID, fileName: thumbFileName)

        let resizedFull = Self.resize(image, maxLongEdge: Self.maxFullImageLongEdge)
        guard let data = resizedFull.jpegData(compressionQuality: Self.fullJPEGQuality) else { return false }

        let thumb = Self.resize(resizedFull, maxLongEdge: Self.maxThumbnailLongEdge)
        guard let thumbData = thumb.jpegData(compressionQuality: Self.thumbnailJPEGQuality) else { return false }

        do {
            try fileManager.createDirectory(at: islandPhotosDirectory(islandID: islandID), withIntermediateDirectories: true)
            try data.write(to: fileURL, options: .atomic)
            try thumbData.write(to: thumbURL, options: .atomic)

            var manifest = loadManifest(for: islandID)
            let photo = IslandSavedPhoto(
                id: photoID,
                islandID: islandID,
                fileName: fileName,
                createdAt: Date(),
                note: ""
            )
            manifest.append(photo)
            try saveManifest(manifest, for: islandID)
            photos = manifest.sorted { $0.createdAt > $1.createdAt }
            thumbnailCache.setObject(thumb, forKey: photoID as NSString)
            return true
        } catch {
            try? fileManager.removeItem(at: fileURL)
            try? fileManager.removeItem(at: thumbURL)
            return false
        }
    }

    /// 写真に付けたメモを端末内マニフェストへ保存する
    func updateNote(_ note: String, for photo: IslandSavedPhoto) {
        var manifest = loadManifest(for: photo.islandID)
        guard let index = manifest.firstIndex(where: { $0.id == photo.id }) else { return }

        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
        guard manifest[index].note != trimmed else { return }

        manifest[index].note = trimmed
        try? saveManifest(manifest, for: photo.islandID)
        photos = manifest.sorted { $0.createdAt > $1.createdAt }
    }

    func deletePhoto(_ photo: IslandSavedPhoto) {
        let fileURL = photoFileURL(islandID: photo.islandID, fileName: photo.fileName)
        let thumbURL = thumbnailFileURL(for: photo)
        try? fileManager.removeItem(at: fileURL)
        try? fileManager.removeItem(at: thumbURL)
        thumbnailCache.removeObject(forKey: photo.id as NSString)

        var manifest = loadManifest(for: photo.islandID)
        manifest.removeAll { $0.id == photo.id }
        try? saveManifest(manifest, for: photo.islandID)
        photos = manifest.sorted { $0.createdAt > $1.createdAt }
    }

    /// グリッド表示用の小さなサムネイル（バックグラウンドで読み込み）
    func thumbnail(for photo: IslandSavedPhoto) async -> UIImage? {
        let cacheKey = photo.id as NSString
        if let cached = thumbnailCache.object(forKey: cacheKey) {
            return cached
        }

        let thumbURL = thumbnailFileURL(for: photo)
        let fullURL = photoFileURL(islandID: photo.islandID, fileName: photo.fileName)

        let image = await Task.detached(priority: .userInitiated) { () -> UIImage? in
            if let data = try? Data(contentsOf: thumbURL),
               let thumbnail = UIImage(data: data) {
                return thumbnail
            }

            // 旧データ用：本画像からサムネを生成して保存する
            guard let data = try? Data(contentsOf: fullURL),
                  let fullImage = UIImage(data: data) else {
                return nil
            }

            let generated = Self.resize(fullImage, maxLongEdge: Self.maxThumbnailLongEdge)
            if let thumbData = generated.jpegData(compressionQuality: Self.thumbnailJPEGQuality) {
                try? thumbData.write(to: thumbURL, options: .atomic)
            }
            return generated
        }.value

        if let image {
            thumbnailCache.setObject(image, forKey: cacheKey)
        }
        return image
    }

    /// 全画面表示用の本画像（バックグラウンドで読み込み）
    func fullImage(for photo: IslandSavedPhoto) async -> UIImage? {
        let fileURL = photoFileURL(islandID: photo.islandID, fileName: photo.fileName)
        return await Task.detached(priority: .userInitiated) { () -> UIImage? in
            guard let data = try? Data(contentsOf: fileURL) else { return nil }
            return UIImage(data: data)
        }.value
    }

    private func ensureStorageDirectoryExists() {
        try? fileManager.createDirectory(at: storageRoot, withIntermediateDirectories: true)
    }

    private func islandPhotosDirectory(islandID: String) -> URL {
        storageRoot.appendingPathComponent(islandID, isDirectory: true)
    }

    private func manifestURL(for islandID: String) -> URL {
        storageRoot.appendingPathComponent("\(islandID)-manifest.json")
    }

    private func photoFileURL(islandID: String, fileName: String) -> URL {
        islandPhotosDirectory(islandID: islandID).appendingPathComponent(fileName)
    }

    private func thumbnailFileURL(for photo: IslandSavedPhoto) -> URL {
        photoFileURL(
            islandID: photo.islandID,
            fileName: Self.thumbnailFileName(for: photo.fileName)
        )
    }

    private nonisolated static func thumbnailFileName(for fileName: String) -> String {
        let base = (fileName as NSString).deletingPathExtension
        return "\(base)-thumb.jpg"
    }

    private nonisolated static func resize(_ image: UIImage, maxLongEdge: CGFloat) -> UIImage {
        let size = image.size
        let longEdge = max(size.width, size.height)
        guard longEdge > maxLongEdge else { return image }

        let scale = maxLongEdge / longEdge
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }

    private func loadManifest(for islandID: String) -> [IslandSavedPhoto] {
        guard let data = try? Data(contentsOf: manifestURL(for: islandID)),
              let decoded = try? JSONDecoder().decode([IslandSavedPhoto].self, from: data) else {
            return []
        }
        return decoded
    }

    private func saveManifest(_ manifest: [IslandSavedPhoto], for islandID: String) throws {
        let data = try JSONEncoder().encode(manifest)
        try data.write(to: manifestURL(for: islandID), options: .atomic)
    }
}
