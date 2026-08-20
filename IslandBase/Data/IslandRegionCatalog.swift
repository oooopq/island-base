//
//  IslandRegionCatalog.swift
//  Island Base
//
//  地域（八重山・佐渡島・伊豆など）の表示名とフェリー取得元の注記
//

import CoreLocation
import Foundation

/// ホーム日本地図のピン配置（本図 / 別枠）とラベルの微調整
struct HomeMapLayout: Hashable {
    enum Placement: Hashable {
        /// 本図の実座標にピンを置く
        case mainMap
        /// 本図の画角から外し、地図内の別枠に実地図を出す（八重山・将来の小笠原など）
        case inset
    }

    var placement: Placement
    /// ピン位置の上書き（緯度）。nil なら登録島の座標平均
    var pinLatitude: Double?
    /// ピン位置の上書き（経度）。nil なら登録島の座標平均
    var pinLongitude: Double?
    /// ピン先端からのラベルオフセット（ポイント）。+x 右、+y 下
    var labelOffsetX: Double
    var labelOffsetY: Double

    init(
        placement: Placement = .mainMap,
        pinLatitude: Double? = nil,
        pinLongitude: Double? = nil,
        labelOffsetX: Double,
        labelOffsetY: Double
    ) {
        self.placement = placement
        self.pinLatitude = pinLatitude
        self.pinLongitude = pinLongitude
        self.labelOffsetX = labelOffsetX
        self.labelOffsetY = labelOffsetY
    }
}

struct IslandRegion: Identifiable, Hashable {
    let id: String
    let displayNameJapanese: String
    let displayNameEnglish: String
    /// ホーム日本地図のピン用ラベル（カードの正式名とは別。地図専用）
    let mapLabelJapanese: String
    let mapLabelEnglish: String
    /// ホーム地図のピン位置・別枠・ラベルずれ
    let homeMap: HomeMapLayout
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
        mapLabelJapanese: "八重山諸島",
        mapLabelEnglish: "Yaeyama Islands",
        homeMap: HomeMapLayout(
            placement: .inset,
            labelOffsetX: 0,
            labelOffsetY: 32
        ),
        coverAssetName: "IslandBgIshigaki",
        coverAssetCredit: "Photo: Roméo A. / Unsplash（石垣島・川平湾）",
        ferryDataSourceNote: "OTTOP 公開 GTFS を改変して表示（CC BY 4.0）。詳細は出典・クレジット参照",
        ferryValidUntilSuffix: "（OTTOP公開データ）"
    )

    static let sado = IslandRegion(
        id: "sado",
        displayNameJapanese: "佐渡島",
        displayNameEnglish: "Sado Island",
        mapLabelJapanese: "佐渡島",
        mapLabelEnglish: "Sado Island",
        homeMap: HomeMapLayout(
            labelOffsetX: -58,
            labelOffsetY: -18
        ),
        coverAssetName: "IslandBgSado",
        coverAssetCredit: "Photo: 伊藤善行 / Wikimedia Commons（佐渡島・矢島経島のたらい舟）／CC BY-SA 3.0／表示時に暗色グラデーションを追加",
        ferryDataSourceNote: nil,
        ferryValidUntilSuffix: nil
    )

    static let izu = IslandRegion(
        id: "izu",
        displayNameJapanese: "伊豆諸島",
        displayNameEnglish: "Izu Islands",
        mapLabelJapanese: "伊豆諸島",
        mapLabelEnglish: "Izu Islands",
        homeMap: HomeMapLayout(
            // 19時（7時）方向。右端で名前が切れないよう地図の内側へ
            labelOffsetX: -36,
            labelOffsetY: 62
        ),
        coverAssetName: "IslandBgIzu",
        coverAssetCredit: "Photo: Ice Tea / Unsplash（神津島・伊豆諸島）",
        ferryDataSourceNote: "ダイヤ・運航状況は東海汽船の公式サイトでご確認ください。",
        ferryValidUntilSuffix: nil
    )

    static let goto = IslandRegion(
        id: "goto",
        displayNameJapanese: "五島列島",
        displayNameEnglish: "Goto Islands",
        mapLabelJapanese: "五島列島",
        mapLabelEnglish: "Goto Islands",
        homeMap: HomeMapLayout(
            // 1時方向。左端で名前が切れないよう地図の内側へ
            labelOffsetX: 36,
            labelOffsetY: -62
        ),
        coverAssetName: "IslandBgGoto",
        coverAssetCredit: "Photo: Nami-ja / Wikimedia Commons（五島市玉之浦町・頓泊海水浴場）／CC BY-SA 4.0／表示時に暗色グラデーションを追加",
        ferryDataSourceNote: "ダイヤ・運航状況は五島旅客船・木口汽船・九州商船等の公式サイトでご確認ください。",
        ferryValidUntilSuffix: nil
    )

    static let kutsuna = IslandRegion(
        id: "kutsuna",
        displayNameJapanese: "忽那諸島",
        displayNameEnglish: "Kutsuna Islands",
        mapLabelJapanese: "忽那諸島",
        mapLabelEnglish: "Kutsuna Islands",
        homeMap: HomeMapLayout(
            // 6時方向（ピンの真下）
            labelOffsetX: 0,
            labelOffsetY: 44
        ),
        coverAssetName: "IslandBgKutsuna",
        coverAssetCredit: "Photo: KUNIO MIURA / Wikimedia Commons（興居島沖合）／CC BY 3.0／表示時に暗色グラデーションを追加",
        ferryDataSourceNote: "ダイヤ・運航状況は中島汽船・ごごしま等の公式サイトでご確認ください。",
        ferryValidUntilSuffix: nil
    )

    static let shodoshimaNaoshima = IslandRegion(
        id: "shodoshima_naoshima",
        displayNameJapanese: "小豆島・直島エリア",
        displayNameEnglish: "Shodoshima & Naoshima",
        mapLabelJapanese: "小豆島・直島",
        mapLabelEnglish: "Shodoshima & Naoshima",
        homeMap: HomeMapLayout(
            // 英語ラベルがピンにかぶらないよう、少し右上へ
            labelOffsetX: 86,
            labelOffsetY: -38
        ),
        coverAssetName: "IslandBgShodoshimaNaoshima",
        coverAssetCredit: "Photo: Yu / Unsplash（小豆島・香川）",
        ferryDataSourceNote: "四国フェリー・小豆島豊島フェリー・四国汽船等の公式サイトからご確認ください。",
        ferryValidUntilSuffix: nil
    )

    static let all: [IslandRegion] = [yaeyama, sado, izu, goto, kutsuna, shodoshimaNaoshima]

    static var homeMapMainRegions: [IslandRegion] {
        all.filter { $0.homeMap.placement == .mainMap }
    }

    static var homeMapInsetRegions: [IslandRegion] {
        all.filter { $0.homeMap.placement == .inset }
    }

    static func region(for regionID: String) -> IslandRegion? {
        all.first { $0.id == regionID }
    }

    static func displayName(for regionID: String, language: AppLanguageMode = .japanese) -> String {
        guard let region = region(for: regionID) else { return regionID }
        return region.displayName(for: language)
    }
}
