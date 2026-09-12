//
//  PlaceCategoryMatching.swift
//  Island Base
//
//  忽那諸島の店舗タブ向け：自然言語検索の結果をカテゴリに合うものだけ残す
//

import MapKit

extension PlaceCategory {
    /// 自然言語検索の1件が、このタブ（飲食・宿・商店）に合うか
    func matchesNaturalLanguageResult(_ mapItem: MKMapItem) -> Bool {
        let name = mapItem.name ?? ""
        if containsExcludedName(name) {
            return false
        }

        if let poiCategory = mapItem.pointOfInterestCategory {
            if excludedPointOfInterestCategories.contains(poiCategory) {
                return false
            }
            if mapKitCategories.contains(poiCategory) {
                return true
            }
            return false
        }

        return containsAllowedName(name)
    }

    /// 郵便局・診療所など、店舗タブに出さない名前
    private func containsExcludedName(_ name: String) -> Bool {
        let excluded = [
            "郵便局",
            "郵便",
            "診療所",
            "病院",
            "医院",
            "クリニック",
            "役場",
            "出張所",
            "支所",
            "小学校",
            "中学校",
            "保育園",
            "幼稚園",
            "公民館",
            "駐在所",
            "交番",
            "消防",
            "灯台",
            "フェリー",
        ]
        return excluded.contains { name.contains($0) }
    }

    /// Apple の種別が無いときの名前ヒント
    private func containsAllowedName(_ name: String) -> Bool {
        allowedNameHints.contains { name.localizedCaseInsensitiveContains($0) }
    }

    private var allowedNameHints: [String] {
        switch self {
        case .restaurant:
            return [
                "レストラン", "食堂", "飲食", "カフェ", "喫茶", "居酒屋",
                "定食", "ラーメン", "そば", "うどん", "寿司", "鮨",
                "弁当", "食事", "ベーカリー", "パン", "cafe", "restaurant",
            ]
        case .lodging:
            return [
                "民宿", "旅館", "ホテル", "ゲストハウス", "ペンション",
                "宿", "民泊", "hotel", "inn", "lodge", "pension",
            ]
        case .shop:
            return [
                "商店", "コンビニ", "スーパー", "売店", "市場",
                "ストア", "雑貨", "土産", "みやげ", "酒屋", "薬局",
                "mart", "store", "shop",
            ]
        }
    }

    /// 宿・飲食に出さない施設種別（商店の薬局は mapKitCategories 側で許可）
    private var excludedPointOfInterestCategories: [MKPointOfInterestCategory] {
        var excluded: [MKPointOfInterestCategory] = [
            .hospital,
            .school,
            .library,
            .police,
            .fireStation,
            .bank,
            .atm,
            .parking,
            .gasStation,
            .marina,
            .airport,
            .beach,
            .park,
            .nationalPark,
            .museum,
            .postOffice,
        ]
        if self != .shop {
            excluded.append(.pharmacy)
        }
        return excluded
    }
}
