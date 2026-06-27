//
//  HeatStrokeRiskInfo.swift
//  Island Now
//
//  環境省 API から取得した WBGT（現在・今日最高）
//

import Foundation

struct HeatStrokeRiskInfo: Codable, Equatable {
    let currentWBGT: Double?
    let todayMaxWBGT: Double

    var currentLevel: WBGTRiskLevel? {
        currentWBGT.map(WBGTRiskLevel.level(for:))
    }

    var todayMaxLevel: WBGTRiskLevel {
        WBGTRiskLevel.level(for: todayMaxWBGT)
    }
}
