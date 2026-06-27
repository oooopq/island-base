//
//  WBGTRiskLevel.swift
//  Island Now
//
//  環境省 WBGT の5段階リスク（数値のみ表示、文言は使わない）
//

import SwiftUI

enum WBGTRiskLevel: Int, Codable, Comparable, CaseIterable {
    case almostSafe = 0
    case caution = 1
    case warning = 2
    case severe = 3
    case danger = 4

    static func level(for wbgt: Double) -> WBGTRiskLevel {
        switch wbgt {
        case ..<21:
            return .almostSafe
        case 21..<25:
            return .caution
        case 25..<28:
            return .warning
        case 28..<31:
            return .severe
        default:
            return .danger
        }
    }

    var color: Color {
        switch self {
        case .almostSafe:
            return Color(red: 0.45, green: 0.78, blue: 0.95)
        case .caution:
            return Color(red: 0.98, green: 0.90, blue: 0.35)
        case .warning:
            return Color(red: 0.98, green: 0.75, blue: 0.20)
        case .severe:
            return Color(red: 0.98, green: 0.55, blue: 0.15)
        case .danger:
            return Color(red: 0.92, green: 0.22, blue: 0.18)
        }
    }

    static func < (lhs: WBGTRiskLevel, rhs: WBGTRiskLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
