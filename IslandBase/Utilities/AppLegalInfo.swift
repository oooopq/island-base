//
//  AppLegalInfo.swift
//  Island Base
//
//  お問い合わせ・規約・プライバシーポリシーの公開 URL
//

import Foundation

enum AppLegalInfo {
    static let supportEmail = "opaquu@gmail.com"

    /// GitHub Pages（リポジトリ Settings → Pages → /docs）
    /// GitHub ユーザー名 oooopq / リポジトリ island-base
    private static let siteBaseURL = "https://oooopq.github.io/island-base"

    static var privacyPolicyURL: URL? {
        AppURL.from(string: "\(siteBaseURL)/privacy-policy.html")
    }

    static var termsOfServiceURL: URL? {
        AppURL.from(string: "\(siteBaseURL)/terms-of-service.html")
    }

    static var supportEmailURL: URL? {
        AppURL.from(string: "mailto:\(supportEmail)")
    }

    static let openMeteoAttributionURL = "https://open-meteo.com/"
    static let openMeteoAttributionText = "Weather data by Open-Meteo.com"

    /// GitHub Pages 上の天気キャッシュ JSON（Actions が毎時更新）
    static let weatherCacheBaseURL = "https://oooopq.github.io/island-base/weather"
    /// Actions の更新間隔（秒）。表示用の目安
    static let weatherCacheUpdateIntervalSeconds = 3600
}
