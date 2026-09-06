//
//  IslandDetailSection.swift
//  Island Base
//
//  島詳細画面で切り替えるセクション
//

import SwiftUI

enum IslandDetailSection: String, CaseIterable, Identifiable {
    case weather
    case schedule
    case places
    case savedPhotos

    var id: String { rawValue }

    var title: String {
        title(for: .japanese)
    }

    func title(for language: AppLanguageMode) -> String {
        switch self {
        case .weather:
            return AppText.weather.string(for: language)
        case .schedule:
            return AppText.schedule.string(for: language)
        case .places:
            return AppText.places.string(for: language)
        case .savedPhotos:
            return AppText.savedPhotos.string(for: language)
        }
    }

    var systemImage: String {
        switch self {
        case .weather:
            return "cloud.sun"
        case .schedule:
            return "calendar.badge.clock"
        case .places:
            return "storefront"
        case .savedPhotos:
            return "photo.on.rectangle"
        }
    }

    /// セクションタブのアイコン色（ダークモード向け）
    var iconColor: Color {
        switch self {
        case .weather:
            return Color(red: 1.0, green: 0.72, blue: 0.18)
        case .schedule:
            return Color(red: 0.18, green: 0.68, blue: 1.0)
        case .places:
            return Color(red: 0.22, green: 0.82, blue: 0.52)
        case .savedPhotos:
            return Color(red: 1.0, green: 0.36, blue: 0.52)
        }
    }

    /// ライトモード向けの高コントラストアイコン色
    var lightModeIconColor: Color {
        switch self {
        case .weather:
            return Color(red: 0.72, green: 0.42, blue: 0.02)
        case .schedule:
            return Color(red: 0.02, green: 0.38, blue: 0.78)
        case .places:
            return Color(red: 0.02, green: 0.48, blue: 0.24)
        case .savedPhotos:
            return Color(red: 0.78, green: 0.08, blue: 0.30)
        }
    }

    func resolvedIconColor(isLightMode: Bool) -> Color {
        isLightMode ? lightModeIconColor : iconColor
    }

    /// 選択中タブのグラデーション
    var tabGradient: LinearGradient {
        switch self {
        case .weather:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.88, blue: 0.35),
                    Color(red: 1.0, green: 0.58, blue: 0.12),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .schedule:
            return LinearGradient(
                colors: [
                    Color(red: 0.45, green: 0.86, blue: 1.0),
                    Color(red: 0.12, green: 0.52, blue: 0.98),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .places:
            return LinearGradient(
                colors: [
                    Color(red: 0.52, green: 0.96, blue: 0.68),
                    Color(red: 0.14, green: 0.72, blue: 0.46),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .savedPhotos:
            return LinearGradient(
                colors: [
                    Color(red: 1.0, green: 0.58, blue: 0.72),
                    Color(red: 0.92, green: 0.24, blue: 0.48),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    /// ライトモード向けの選択中タブグラデーション（白文字とのコントラスト確保）
    var lightModeTabGradient: LinearGradient {
        switch self {
        case .weather:
            return LinearGradient(
                colors: [
                    Color(red: 0.98, green: 0.72, blue: 0.12),
                    Color(red: 0.82, green: 0.42, blue: 0.02),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .schedule:
            return LinearGradient(
                colors: [
                    Color(red: 0.22, green: 0.62, blue: 0.98),
                    Color(red: 0.02, green: 0.34, blue: 0.82),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .places:
            return LinearGradient(
                colors: [
                    Color(red: 0.28, green: 0.78, blue: 0.48),
                    Color(red: 0.02, green: 0.52, blue: 0.28),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .savedPhotos:
            return LinearGradient(
                colors: [
                    Color(red: 0.92, green: 0.28, blue: 0.48),
                    Color(red: 0.72, green: 0.08, blue: 0.30),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    func resolvedTabGradient(isLightMode: Bool) -> LinearGradient {
        isLightMode ? lightModeTabGradient : tabGradient
    }

    // MARK: - Light Mode（未選択）

    /// 未選択タブの neutral 下地（systemGray5 相当）
    static let lightUnselectedSurface = Color(uiColor: .systemGray5)

    /// 未選択タブのカテゴリ色ヒント（背景）
    func lightModeUnselectedCategoryTint() -> Color {
        resolvedIconColor(isLightMode: true).opacity(0.025)
    }

    /// 未選択タブの border（neutral 基本）
    static let lightUnselectedBorder = Color.black.opacity(0.10)

    /// 未選択アイコン円（カテゴリ色ヒント）
    func lightModeUnselectedIconCircleFill() -> Color {
        resolvedIconColor(isLightMode: true).opacity(0.10)
    }

    /// 未選択アイコン第2色
    func lightModeUnselectedIconSecondaryColor() -> Color {
        resolvedIconColor(isLightMode: true).opacity(0.36)
    }

    /// 未選択アイコン・ラベル（彩度を少し落とす）
    func lightModeUnselectedForegroundColor() -> Color {
        resolvedIconColor(isLightMode: true).opacity(0.66)
    }

    // MARK: - Dark Mode（未選択）

    func darkModeUnselectedTabBackground() -> Color {
        iconColor.opacity(0.04)
    }

    func darkModeUnselectedTabBorder() -> Color {
        iconColor.opacity(0.22)
    }

    func darkModeUnselectedIconCircleFill() -> Color {
        iconColor.opacity(0.12)
    }

    func darkModeUnselectedIconSecondaryColor() -> Color {
        iconColor.opacity(0.30)
    }

    func darkModeUnselectedForegroundColor() -> Color {
        iconColor.opacity(0.70)
    }
}
