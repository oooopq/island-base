//
//  CacheAgeText.swift
//  Island Now
//
//  キャッシュデータの取得時刻を読みやすい日本語にする
//

import Foundation

enum CacheAgeText {
    /// 例: 「3時間前に取得したデータを表示中」
    static func displayText(fetchedAt: Date?, isFromCache: Bool) -> String? {
        guard isFromCache else { return nil }
        guard let fetchedAt else {
            return "前回取得したデータを表示中"
        }

        let age = Date().timeIntervalSince(fetchedAt)
        if age < 60 {
            return "たった今取得したデータを表示中"
        }
        if age < 3600 {
            let minutes = max(1, Int(age / 60))
            return "\(minutes)分前に取得したデータを表示中"
        }
        if age < 86_400 {
            let hours = max(1, Int(age / 3600))
            return "\(hours)時間前に取得したデータを表示中"
        }

        let days = max(1, Int(age / 86_400))
        return "\(days)日前に取得したデータを表示中"
    }
}
