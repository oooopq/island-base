//
//  HeatStrokeRiskLoadState.swift
//  Island Now
//
//  熱中症リスク（WBGT）の表示状態
//

import Foundation

enum HeatStrokeRiskLoadState: Equatable {
    case unavailable
    case loading
    case loaded(HeatStrokeRiskInfo, isFromCache: Bool)
    case failed
}
