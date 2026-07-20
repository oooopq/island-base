//
//  FerryLoadState.swift
//  Island Base
//
//  フェリーダイヤセクションの表示状態
//

import Foundation

enum FerryLoadState {
    case loading
    case loaded(
        [FerryCompanySchedule],
        isFromCache: Bool,
        validUntilText: String?,
        fetchedAt: Date?
    )
    case failed(message: String, cachedSchedules: [FerryCompanySchedule]?, fetchedAt: Date?)

    var debugKey: String {
        switch self {
        case .loading:
            return "loading"
        case .loaded(let schedules, let isFromCache, _, _):
            let tripCount = schedules.reduce(0) { $0 + $1.trips.count }
            return "loaded-\(tripCount)-\(isFromCache)"
        case .failed(let message, _, _):
            return "failed-\(message)"
        }
    }
}
