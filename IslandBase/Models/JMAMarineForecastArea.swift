//
//  JMAMarineForecastArea.swift
//  Island Base
//
//  気象庁「海上警報・予報」の細分海域（area_code）
//

import Foundation

struct JMAMarineForecastArea: Hashable, Sendable {
    let code: String

    func displayName(for language: AppLanguageMode) -> String {
        JMAMarineForecastCatalog.displayName(for: code, language: language)
    }

    func forecastURL(for language: AppLanguageMode) -> URL? {
        JMAMarineForecastCatalog.forecastURL(areaCode: code, language: language)
    }
}

extension JMAMarineForecastArea {
    /// 瀬戸内海
    static let setonaikai = JMAMarineForecastArea(code: "4010")
    /// 佐渡沖
    static let sadoOffshore = JMAMarineForecastArea(code: "3130")
    /// 長崎西海上
    static let nagasakiWest = JMAMarineForecastArea(code: "5120")
    /// 東シナ海南部
    static let eastChinaSouth = JMAMarineForecastArea(code: "6010")
    /// 沖縄東方海上
    static let okinawaEast = JMAMarineForecastArea(code: "6020")
    /// 沖縄南方海上
    static let okinawaSouth = JMAMarineForecastArea(code: "6030")
    /// 関東海域北部
    static let kantoNorth = JMAMarineForecastArea(code: "3010")
    /// 関東海域南部
    static let kantoSouth = JMAMarineForecastArea(code: "3020")
}
