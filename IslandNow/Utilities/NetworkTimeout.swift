//
//  NetworkTimeout.swift
//  Island Now
//
//  圏外時に長く待たないための短いタイムアウト
//

import Foundation

enum NetworkTimeout {
    /// キャッシュがないときの待ち時間（秒）
    static let shortSeconds: TimeInterval = 5

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

            guard let result = try await group.next() else {
                throw TimeoutError.timedOut
            }
            group.cancelAll()
            return result
        }
    }
}
