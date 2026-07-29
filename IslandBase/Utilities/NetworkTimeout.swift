//
//  NetworkTimeout.swift
//  Island Base
//
//  圏外時に長く待たないための短いタイムアウト
//

import Foundation

enum NetworkTimeout {
    /// キャッシュがないときの待ち時間（秒）— ダイヤ・店舗など
    static let shortSeconds: TimeInterval = 8
    /// GitHub Pages の天気 JSON（静的 CDN・軽量のため短め）
    static let weatherPagesSeconds: TimeInterval = 8

    enum TimeoutError: Error {
        case timedOut
    }

    /// 指定秒数以内に終わらなければタイムアウトにする
    static func withTimeout<T>(
        seconds: TimeInterval = shortSeconds,
        operation: @escaping @Sendable () async throws -> T
    ) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }
            group.addTask {
                try await Task.sleep(for: .seconds(seconds))
                throw TimeoutError.timedOut
            }

            defer { group.cancelAll() }

            guard let result = try await group.next() else {
                throw TimeoutError.timedOut
            }
            return result
        }
    }
}
