//
//  IslandRegionCatalog.swift
//  Island Now
//
//  地域（八重山・佐渡・伊豆など）の表示名とフェリー取得元の注記
//

import CoreLocation
import Foundation

struct IslandRegion: Identifiable, Hashable {
    let id: String
    let displayNameJapanese: String
    /// 日本地図ホームのピン位置（代表島・諸島の目安）
    let mapAnnotationLatitude: Double
    let mapAnnotationLongitude: Double
    /// ホーム画面カード用の背景画像（Assets）
    let coverAssetName: String
    /// フェリーダイヤ取得元の説明（GTFS 取得時のフッター用）
    let ferryDataSourceNote: String?
    /// 有効期限表示の接尾辞（例: OTTOP）
    let ferryValidUntilSuffix: String?

    static func == (lhs: IslandRegion, rhs: IslandRegion) -> Bool {
        lhs.id == rhs.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    var mapCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: mapAnnotationLatitude, longitude: mapAnnotationLongitude)
    }
}

enum IslandRegionCatalog {
    static let yaeyama = IslandRegion(
        id: "yaeyama",
        displayNameJapanese: "八重山諸島",
        mapAnnotationLatitude: 24.432805,
        mapAnnotationLongitude: 124.205319,
        coverAssetName: "IslandBgIshigaki",
        ferryDataSourceNote: "沖縄公共交通オープンデータ（OTTOP）から取得しています",
        ferryValidUntilSuffix: "（OTTOP公開データ）"
    )

    static let sado = IslandRegion(
        id: "sado",
        displayNameJapanese: "佐渡",
        mapAnnotationLatitude: 38.044270,
        mapAnnotationLongitude: 138.437949,
        coverAssetName: "IslandBgSado",
        ferryDataSourceNote: nil,
        ferryValidUntilSuffix: nil
    )

    static let izu = IslandRegion(
        id: "izu",
        displayNameJapanese: "伊豆諸島",
        mapAnnotationLatitude: 34.737500,
        mapAnnotationLongitude: 139.398817,
        coverAssetName: "IslandBgIzu",
        ferryDataSourceNote: "東海汽船の代表ダイヤです。高速船（日中）と大型客船（夜航）を分けて表示しています。",
        ferryValidUntilSuffix: nil
    )

    static let goto = IslandRegion(
        id: "goto",
        displayNameJapanese: "五島列島",
        mapAnnotationLatitude: 32.686123,
        mapAnnotationLongitude: 128.747749,
        coverAssetName: "IslandBgGoto",
        ferryDataSourceNote: "五島旅客船・木口汽船・九州商船等の代表ダイヤです。カーフェリー（OCEAN）と高速船（TAIYO・シーガル）を分けて表示しています。",
        ferryValidUntilSuffix: nil
    )

    static let kutsuna = IslandRegion(
        id: "kutsuna",
        displayNameJapanese: "忽那諸島",
        mapAnnotationLatitude: 33.980615,
        mapAnnotationLongitude: 132.615204,
        coverAssetName: "IslandBgKutsuna",
        ferryDataSourceNote: "中島汽船・ごごしま等の代表ダイヤです。フェリーと高速船を分けて表示。東線・西線で寄港が異なります。",
        ferryValidUntilSuffix: nil
    )

    static let all: [IslandRegion] = [yaeyama, sado, izu, goto, kutsuna]

    static func region(for regionID: String) -> IslandRegion? {
        all.first { $0.id == regionID }
    }

    static func displayName(for regionID: String) -> String {
        region(for: regionID)?.displayNameJapanese ?? regionID
    }
}
