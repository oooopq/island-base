//
//  PhotoCreditText.swift
//  Island Base
//
//  背景写真クレジットの日英。撮影者名・ライセンス・出典サイト名は共通。
//  日本語の組み立て結果は、従来の1行クレジットと同一になる。
//

import Foundation

enum PhotoCreditText {
    /// 日本語クレジット末尾。表示文言はこれを唯一の定義にする。
    static let darkGradientAddedJapanese = "表示時に暗色グラデーションを追加"
    static let darkGradientAddedEnglish = "dark gradient added for display"

    static func japanese(
        attribution: String,
        place: String,
        license: String? = nil,
        addsDarkGradient: Bool = false
    ) -> String {
        line(
            attribution: attribution,
            place: place,
            license: license,
            addsDarkGradient: addsDarkGradient,
            language: .japanese
        )
    }

    static func english(
        attribution: String,
        place: String,
        license: String? = nil,
        addsDarkGradient: Bool = false
    ) -> String {
        line(
            attribution: attribution,
            place: place,
            license: license,
            addsDarkGradient: addsDarkGradient,
            language: .english
        )
    }

    private static func line(
        attribution: String,
        place: String,
        license: String?,
        addsDarkGradient: Bool,
        language: AppLanguageMode
    ) -> String {
        var text = attribution
        if language.isJapanese {
            text += "（\(place)）"
        } else {
            text += " (\(place))"
        }

        let separator = language.isJapanese ? "／" : " / "
        if let license, license.isEmpty == false {
            text += separator + license
        }
        if addsDarkGradient {
            let phrase = language.isJapanese ? darkGradientAddedJapanese : darkGradientAddedEnglish
            text += separator + phrase
        }
        return text
    }
}
