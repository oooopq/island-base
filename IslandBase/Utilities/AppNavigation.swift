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

extension EnvironmentValues {
    var popToHome: () -> Void {
        get { self[PopToHomeKey.self] }
        set { self[PopToHomeKey.self] = newValue }
    }
}
