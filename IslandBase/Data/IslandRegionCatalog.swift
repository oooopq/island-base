//
//  IslandRegionCatalog.swift
//  Island Base
//
//  地域（八重山・佐渡・伊豆など）の表示名とフェリー取得元の注記
//

import CoreLocation
import Foundation

struct IslandRegion: Identifiable, Hashable {
    let id: String
    let displayNameJapanese: String
    let displayNameEnglish: String
    /// 日本地図ホームのピン用の短い名前（長い正式名は下の一覧に残す）
    let mapLabelJapanese: String
    let mapLabelEnglish: String
    /// 日本地図ホームのピン位置（見やすさのため実座標から少しずらす場合あり）
    let mapAnnotationLatitude: Double
    let mapAnnotationLongitude: Double
    /// ホーム画面カード用の背景画像（Assets）
    let coverAssetName: String
    /// 地域カバー画像の出典表記（Unsplash 等）
    let coverAssetCredit: String?
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

    func displayName(for language: AppLanguageMode) -> String {
        language.isJapanese ? displayNameJapanese : displayNameEnglish
    }

    func mapLabel(for language: AppLanguageMode) -> String {
        language.isJapanese ? mapLabelJapanese : mapLabelEnglish
    }
}

enum IslandRegionCatalog {
    static let yaeyama = IslandRegion(
        id: "yaeyama",
        displayNameJapanese: "八重山諸島",
        displayNameEnglish: "Yaeyama Islands",
        mapLabelJapanese: "八重山",
        mapLabelEnglish: "Yaeyama",
        mapAnnotationLatitude: 24.432805,
        mapAnnotationLongitude: 124.205319,
        coverAssetName: "IslandBgIshigaki",
        coverAssetCredit: "Photo: Roméo A. / Unsplash（石垣島・川平湾）",
        ferryDataSourceNote: "沖縄公共交通オープンデータ（OTTOP）から取得しています",
        ferryValidUntilSuffix: "（OTTOP公開データ）"
    )

    static let sado = IslandRegion(
        id: "sado",
        displayNameJapanese: "佐渡",
        displayNameEnglish: "Sado",
        mapLabelJapanese: "佐渡",
        mapLabelEnglish: "Sado",
        mapAnnotationLatitude: 38.044270,
        mapAnnotationLongitude: 138.437949,
        coverAssetName: "IslandBgSado",
        coverAssetCredit: "Photo: 伊藤善行 / Wikimedia Commons（佐渡・矢島経島のたらい舟）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        ferryDataSourceNote: nil,
        ferryValidUntilSuffix: nil
    )

    static let izu = IslandRegion(
        id: "izu",
        displayNameJapanese: "伊豆諸島",
        displayNameEnglish: "Izu Islands",
        mapLabelJapanese: "伊豆",
        mapLabelEnglish: "Izu",
        mapAnnotationLatitude: 34.737500,
        mapAnnotationLongitude: 139.398817,
        coverAssetName: "IslandBgIzu",
        coverAssetCredit: "Photo: Ice Tea / Unsplash（神津島・伊豆諸島）",
        ferryDataSourceNote: "ダイヤ・運航状況は東海汽船の公式サイトでご確認ください。",
        ferryValidUntilSuffix: nil
    )

    static let goto = IslandRegion(
        id: "goto",
        displayNameJapanese: "五島列島",
        displayNameEnglish: "Goto Islands",
        mapLabelJapanese: "五島",
        mapLabelEnglish: "Goto",
        mapAnnotationLatitude: 32.686123,
        mapAnnotationLongitude: 128.747749,
        coverAssetName: "IslandBgGoto",
        coverAssetCredit: "Photo: Nami-ja / Wikimedia Commons（五島市玉之浦町・頓泊海水浴場）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        ferryDataSourceNote: "ダイヤ・運航状況は五島旅客船・木口汽船・九州商船等の公式サイトでご確認ください。",
        ferryValidUntilSuffix: nil
    )

    // ピンは見やすさのため南西へ（小豆・直島と重ならないように）
    static let kutsuna = IslandRegion(
        id: "kutsuna",
        displayNameJapanese: "忽那諸島",
        displayNameEnglish: "Kutsuna Islands",
        mapLabelJapanese: "忽那",
        mapLabelEnglish: "Kutsuna",
        mapAnnotationLatitude: 33.45,
        mapAnnotationLongitude: 131.95,
        coverAssetName: "IslandBgKutsuna",
        coverAssetCredit: "Photo: KUNIO MIURA / Wikimedia Commons（興居島沖合）／CC BY 3.0／表示時に暗色グラデーションを追加",
        ferryDataSourceNote: "ダイヤ・運航状況は中島汽船・ごごしま等の公式サイトでご確認ください。",
        ferryValidUntilSuffix: nil
    )

    // ピンは見やすさのため北東へ（忽那と重ならないように）
    static let shodoshimaNaoshima = IslandRegion(
        id: "shodoshima_naoshima",
        displayNameJapanese: "小豆島・直島諸島",
        displayNameEnglish: "Shodoshima & Naoshima",
        mapLabelJapanese: "小豆・直島",
        mapLabelEnglish: "Shodo·Nao",
        mapAnnotationLatitude: 34.95,
        mapAnnotationLongitude: 134.75,
        coverAssetName: "IslandBgShodoshimaNaoshima",
        coverAssetCredit: "Photo: Yu / Unsplash（小豆島・香川）",
        ferryDataSourceNote: "四国フェリー・小豆島豊島フェリー・四国汽船等の公式サイトからご確認ください。",
        ferryValidUntilSuffix: nil
    )

    static let all: [IslandRegion] = [yaeyama, sado, izu, goto, kutsuna, shodoshimaNaoshima]

    static func region(for regionID: String) -> IslandRegion? {
        all.first { $0.id == regionID }
    }

    static func displayName(for regionID: String, language: AppLanguageMode = .japanese) -> String {
        guard let region = region(for: regionID) else { return regionID }
        return region.displayName(for: language)
    }
}
