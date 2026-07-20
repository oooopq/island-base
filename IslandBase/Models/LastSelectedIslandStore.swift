//
//  LastSelectedIslandStore.swift
//  Island Base
//
//  最近開いた島を端末内に記憶する（最大2件）
//

import SwiftUI

@Observable
final class LastSelectedIslandStore {
    private static let storageKey = "recentIslandIDs"
    private static let legacyStorageKey = "lastSelectedIslandID"
    private static let maxCount = 2

    private(set) var islandIDs: [String] = []

    var islands: [Island] {
        islandIDs.compactMap { IslandCatalog.profile(for: $0)?.island }
    }

    init() {
        islandIDs = Self.loadIslandIDs()
    }

    func record(_ island: Island) {
        var updatedIDs = islandIDs.filter { $0 != island.id }
        updatedIDs.insert(island.id, at: 0)
        islandIDs = Array(updatedIDs.prefix(Self.maxCount))
        UserDefaults.standard.set(islandIDs, forKey: Self.storageKey)
    }

    private static func loadIslandIDs() -> [String] {
        if let savedIDs = UserDefaults.standard.stringArray(forKey: storageKey) {
            return normalize(savedIDs)
        }

        if let legacyID = UserDefaults.standard.string(forKey: legacyStorageKey) {
            let migrated = normalize([legacyID])
            UserDefaults.standard.set(migrated, forKey: storageKey)
            UserDefaults.standard.removeObject(forKey: legacyStorageKey)
            return migrated
        }

        return []
    }

    private static func normalize(_ ids: [String]) -> [String] {
        var seen = Set<String>()
        var normalized: [String] = []

        for id in ids {
            guard IslandCatalog.profile(for: id) != nil else { continue }
            guard seen.insert(id).inserted else { continue }
            normalized.append(id)
            if normalized.count >= maxCount {
                break
            }
        }

        return normalized
    }
}
