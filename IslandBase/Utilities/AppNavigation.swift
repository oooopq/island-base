//
//  AppNavigation.swift
//  Island Base
//
//  ナビゲーションスタックをルート（トップ画面）へ戻す
//

import SwiftUI

private struct PopToHomeKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

private struct NavigateToRegionKey: EnvironmentKey {
    static let defaultValue: (String) -> Void = { _ in }
}

extension EnvironmentValues {
    var popToHome: () -> Void {
        get { self[PopToHomeKey.self] }
        set { self[PopToHomeKey.self] = newValue }
    }

    /// 地図ピンから諸島一覧へ進む（NavigationPath に載せる）
    var navigateToRegion: (String) -> Void {
        get { self[NavigateToRegionKey.self] }
        set { self[NavigateToRegionKey.self] = newValue }
    }
}
