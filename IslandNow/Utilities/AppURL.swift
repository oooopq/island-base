//
//  AppURL.swift
//  Island Now
//
//  アプリ内リンク用 URL の正規化
//

import Foundation

enum AppURL {
    static func from(string: String?) -> URL? {
        guard var raw = string?.trimmingCharacters(in: .whitespacesAndNewlines),
              raw.isEmpty == false else {
            return nil
        }

        if let url = URL(string: raw), url.scheme != nil {
            return url
        }

        return URL(string: "https://\(raw)")
    }
}
