//
//  CacheAgeText.swift
//  Island Base
//
//  キャッシュデータの取得時刻を読みやすくする
//

import Foundation

enum CacheAgeText {
    /// 例: 「3時間前に取得したデータを表示中」
    static func displayText(
        fetchedAt: Date?,
        isFromCache: Bool,
        language: AppLanguageMode = .japanese
    ) -> String? {
        guard isFromCache else { return nil }
        guard let fetchedAt else {
            return AppText.cachePrevious.string(for: language)
        }

        let age = Date().timeIntervalSince(fetchedAt)
        if age < 60 {
            return AppText.cacheJustNow.string(for: language)
        }
        if age < 3600 {
            let minutes = max(1, Int(age / 60))
            return AppText.cacheMinutesAgo(minutes).string(for: language)
        }
        if age < 86_400 {
            let hours = max(1, Int(age / 3600))
            return AppText.cacheHoursAgo(hours).string(for: language)
        }

        let days = max(1, Int(age / 86_400))
        return AppText.cacheDaysAgo(days).string(for: language)
    }
}
