//
//  IslandDetailSection.swift
//  Island Now
//
//  島詳細画面で切り替えるセクション
//

import Foundation

enum IslandDetailSection: String, CaseIterable, Identifiable {
    case weather
    case schedule
    case places
    case liveCamera

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weather:
            return "天気"
        case .schedule:
            return "ダイヤ"
        case .places:
            return "店舗"
        case .liveCamera:
            return "カメラ"
        }
    }

    var systemImage: String {
        switch self {
        case .weather:
            return "cloud.sun.fill"
        case .schedule:
            return "ferry.fill"
        case .places:
            return "bag.fill"
        case .liveCamera:
            return "video.fill"
        }
    }
}
