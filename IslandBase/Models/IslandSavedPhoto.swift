//
//  IslandSavedPhoto.swift
//  Island Base
//
//  島ごとに端末内へ保存したダイヤ写真のメタデータ
//

import Foundation

struct IslandSavedPhoto: Identifiable, Codable, Hashable {
    let id: String
    let islandID: String
    let fileName: String
    let createdAt: Date
    /// 利用者が写真に付けた短いメモ（端末内のみ）
    var note: String

    private enum CodingKeys: String, CodingKey {
        case id
        case islandID
        case fileName
        case createdAt
        case note
    }

    init(
        id: String,
        islandID: String,
        fileName: String,
        createdAt: Date,
        note: String = ""
    ) {
        self.id = id
        self.islandID = islandID
        self.fileName = fileName
        self.createdAt = createdAt
        self.note = note
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        islandID = try container.decode(String.self, forKey: .islandID)
        fileName = try container.decode(String.self, forKey: .fileName)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        // 旧データには note がないので、空文字として読み込む
        note = try container.decodeIfPresent(String.self, forKey: .note) ?? ""
    }
}
