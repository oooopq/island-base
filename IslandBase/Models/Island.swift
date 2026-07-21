//
//  Island.swift
//  Island Base
//
//  島1件分の基本データ（名前・地図上の島中心座標）
//

import CoreLocation
import Foundation

struct Island: Identifiable, Hashable {
    let id: String
    let nameJapanese: String
    let nameEnglish: String
    /// 地図の島アイコン・店舗検索の基準点（島のおおよその中心。港座標・天気地点とは別）
    let latitude: Double
    let longitude: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    /// いまの言語で主に出す島名
    func primaryName(for language: AppLanguageMode) -> String {
        language.isJapanese ? nameJapanese : nameEnglish
    }

    /// 副表示の島名（主と反対側）
    func secondaryName(for language: AppLanguageMode) -> String {
        language.isJapanese ? nameEnglish : nameJapanese
    }
}
