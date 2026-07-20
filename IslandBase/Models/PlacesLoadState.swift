//
//  PlacesLoadState.swift
//  Island Base
//
//  スポットセクションの表示状態
//

import Foundation

enum PlacesLoadState: Equatable {
    case loading
    case loaded([PlaceInfo], isFromCache: Bool, fetchedAt: Date?)
    case failed(message: String, cachedPlaces: [PlaceInfo]?, fetchedAt: Date?)
}
