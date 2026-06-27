//
//  IslandRegionCatalog.swift
//  Island Now
//
//  地域（八重山・佐渡・伊豆など）の表示名とフェリー取得元の注記
//

import Foundation

struct IslandRegion: Identifiable {
    let id: String
    let displayNameJapanese: String
    /// フェリーダイヤ取得元の説明（GTFS 取得時のフッター用）
    let ferryDataSourceNote: String?
    /// 有効期限表示の接尾辞（例: OTTOP）
    let ferryValidUntilSuffix: String?
}

enum IslandRegionCatalog {
    static let yaeyama = IslandRegion(
        id: "yaeyama",
        displayNameJapanese: "八重山諸島",
        ferryDataSourceNote: "沖縄公共交通オープンデータ（OTTOP）から取得しています",
        ferryValidUntilSuffix: "（OTTOP公開データ）"
    )

    static let sado = IslandRegion(
        id: "sado",
        displayNameJapanese: "佐渡",
        ferryDataSourceNote: nil,
        ferryValidUntilSuffix: nil
    )

    static let izu = IslandRegion(
        id: "izu",
        displayNameJapanese: "伊豆諸島",
        ferryDataSourceNote: nil,
        ferryValidUntilSuffix: nil
    )

    private static let allRegions: [IslandRegion] = [yaeyama, sado, izu]

    static func region(for regionID: String) -> IslandRegion? {
        allRegions.first { $0.id == regionID }
    }

    static func displayName(for regionID: String) -> String {
        region(for: regionID)?.displayNameJapanese ?? regionID
    }
}
