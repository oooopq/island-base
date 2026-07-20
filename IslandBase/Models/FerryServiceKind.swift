//
//  FerryServiceKind.swift
//  Island Base
//
//  船便の種類（高速船・夜航客船など）
//

import Foundation

enum FerryServiceKind: String, Codable, CaseIterable {
    case highSpeedBoat
    case overnightFerry

    var titleEnglish: String {
        switch self {
        case .highSpeedBoat:
            return "High-Speed Boat"
        case .overnightFerry:
            return "Overnight Ferry"
        }
    }

    var titleJapanese: String {
        switch self {
        case .highSpeedBoat:
            return "高速船"
        case .overnightFerry:
            return "大型客船（夜航）"
        }
    }

    var descriptionEnglish: String {
        switch self {
        case .highSpeedBoat:
            return "Day service · About 2–3 hours · Reserved seats"
        case .overnightFerry:
            return "Evening departure · Arrives next morning · Sleeper berths available"
        }
    }

    var descriptionJapanese: String {
        switch self {
        case .highSpeedBoat:
            return "日中運航 · 約2〜3時間 · 指定席"
        case .overnightFerry:
            return "夜出港 · 翌朝着 · 2等寝台あり"
        }
    }

    var systemImage: String {
        switch self {
        case .highSpeedBoat:
            return "ferry.fill"
        case .overnightFerry:
            return "moon.stars.fill"
        }
    }

    var shortLabel: String {
        "\(titleJapanese) / \(titleEnglish)"
    }

    func title(for language: AppLanguageMode) -> String {
        language.isJapanese ? titleJapanese : titleEnglish
    }

    func description(for language: AppLanguageMode) -> String {
        language.isJapanese ? descriptionJapanese : descriptionEnglish
    }
}
