//
//  AppLog.swift
//  Island Base
//
//  画面には出さない開発用ログ。写真の中身・メモ・位置情報は書かない
//

import os

enum AppLog {
    static let photos = Logger(subsystem: "com.tomoyuki.Island-Base", category: "photos")
    static let network = Logger(subsystem: "com.tomoyuki.Island-Base", category: "network")

    /// 写真の中身やメモは渡さない
    static func photoError(_ message: String) {
        photos.error("\(message, privacy: .public)")
    }

    /// 位置情報や通信先の中身は渡さない
    static func networkError(_ message: String) {
        network.error("\(message, privacy: .public)")
    }
}
