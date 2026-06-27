//
//  AppLegalInfo.swift
//  Island Now
//
//  お問い合わせ・規約・プライバシーポリシーの公開 URL
//

import Foundation

enum AppLegalInfo {
    static let supportEmail = "opaquu@gmail.com"

    /// GitHub Pages（リポジトリ Settings → Pages → /docs）公開後のベース URL
    private static let siteBaseURL = "https://opaquu.github.io/island-now"

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
}
