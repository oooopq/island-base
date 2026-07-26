//
//  JMAMarineForecastCatalog.swift
//  Island Base
//
//  気象庁 bosai/seawarning の細分海域コードと表示名
//

import Foundation

enum JMAMarineForecastCatalog {
    private static let baseURL = "https://www.jma.go.jp/bosai/seawarning/"

    private static let names: [String: (japanese: String, english: String)] = [
        "3010": ("関東海域北部", "Northern Sea off Kanto"),
        "3020": ("関東海域南部", "Southern Sea off Kanto"),
        "3130": ("佐渡沖", "Sea off Sado"),
        "4010": ("瀬戸内海", "Setonaikai"),
        "5120": ("長崎西海上", "Sea west of Nagasaki"),
        "6010": ("東シナ海南部", "Southern East China Sea"),
        "6020": ("沖縄東方海上", "Sea east of Okinawa"),
        "6030": ("沖縄南方海上", "Sea south of Okinawa"),
    ]

    static func displayName(for areaCode: String, language: AppLanguageMode) -> String {
        guard let entry = names[areaCode] else { return areaCode }
        return language.isJapanese ? entry.japanese : entry.english
    }

    static func forecastURL(areaCode: String, language: AppLanguageMode) -> URL? {
        var urlString = "\(baseURL)#area_code=\(areaCode)"
        if language.isJapanese == false {
            urlString += "&lang=en"
        }
        return AppURL.from(string: urlString)
    }
}
