//
//  NetworkConnectivity.swift
//  Island Base
//
//  圏外・機内モードの判定（天気などの取得前に使う）
//

import Network

enum NetworkConnectivity {
    /// インターネットに出られる状態か（機内モード・圏外は false）
    static var isConnected: Bool {
        let monitor = NWPathMonitor()
        let connected = monitor.currentPath.status == .satisfied
        monitor.cancel()
        return connected
    }
}
