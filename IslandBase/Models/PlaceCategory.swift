//
//  PlaceCategory.swift
//  Island Base
//
//  スポット検索のカテゴリ（飲食店・宿・商店）
//

import MapKit

enum PlaceCategory: String, CaseIterable, Identifiable {
    case restaurant = "飲食店"
    case lodging = "宿"
    case shop = "商店"

    var id: String { rawValue }

    func title(for language: AppLanguageMode) -> String {
        switch (self, language) {
        case (.restaurant, .japanese): return "飲食店"
        case (.restaurant, .english): return "Food"
        case (.lodging, .japanese): return "宿"
        case (.lodging, .english): return "Stay"
        case (.shop, .japanese): return "商店"
        case (.shop, .english): return "Shop"
        }
    }

    var systemImage: String {
        switch self {
        case .restaurant:
            return "fork.knife"
        case .lodging:
            return "bed.double.fill"
        case .shop:
            return "bag.fill"
        }
    }

    // Apple マップの POI カテゴリに対応づける
    var mapKitCategories: [MKPointOfInterestCategory] {
        switch self {
        case .restaurant:
            return [.restaurant, .cafe, .bakery, .foodMarket]
        case .lodging:
            return [.hotel, .campground]
        case .shop:
            return [.store, .foodMarket, .pharmacy]
        }
    }
}
