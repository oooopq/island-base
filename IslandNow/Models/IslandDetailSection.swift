//
//  IslandDetailSection.swift
//  Island Now
//
//  島詳細画面で切り替えるセクション
//

import SwiftUI

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

    /// セクションタブのアイコン色
    var iconColor: Color {
        switch self {
        case .weather:
            return Color(red: 1.0, green: 0.78, blue: 0.28)
        case .schedule:
            return Color(red: 0.35, green: 0.72, blue: 0.98)
        case .places:
            return Color(red: 0.42, green: 0.84, blue: 0.58)
        case .liveCamera:
            return Color(red: 0.96, green: 0.42, blue: 0.48)
        }
    }
}
