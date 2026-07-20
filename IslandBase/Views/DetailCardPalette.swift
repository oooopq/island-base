//
//  DetailCardPalette.swift
//  Island Base
//
//  詳細画面カードの色（ダーク / ライト）
//

import SwiftUI

struct DetailCardPalette: Equatable {
    let text: Color
    let secondaryText: Color
    let accent: Color
    let iconAccent: Color
    let warning: Color
    let cardBackground: Color
    let cardBorder: Color
    let noticeBackground: Color
    let bannerBackground: Color
    /// 欠航・遅延確認バナー（ライト/ダークとも背景コントラストを確保）
    let scheduleStatusBackground: Color
    let scheduleStatusBorder: Color
    let scheduleStatusSecondaryText: Color
    let hourlySlotBackground: Color
    let captionOnPhoto: Color
    let cardShadow: Color

    func chipBackground(isSelected: Bool) -> Color {
        isSelected ? accent.opacity(0.32) : chipBackgroundUnselected
    }

    func chipForeground(isSelected: Bool) -> Color {
        isSelected ? accent : secondaryText
    }

    private let chipBackgroundUnselected: Color

    init(
        text: Color,
        secondaryText: Color,
        accent: Color,
        iconAccent: Color,
        warning: Color,
        cardBackground: Color,
        cardBorder: Color,
        noticeBackground: Color,
        bannerBackground: Color,
        scheduleStatusBackground: Color,
        scheduleStatusBorder: Color,
        scheduleStatusSecondaryText: Color,
        hourlySlotBackground: Color,
        captionOnPhoto: Color,
        cardShadow: Color,
        chipBackgroundUnselected: Color
    ) {
        self.text = text
        self.secondaryText = secondaryText
        self.accent = accent
        self.iconAccent = iconAccent
        self.warning = warning
        self.cardBackground = cardBackground
        self.cardBorder = cardBorder
        self.noticeBackground = noticeBackground
        self.bannerBackground = bannerBackground
        self.scheduleStatusBackground = scheduleStatusBackground
        self.scheduleStatusBorder = scheduleStatusBorder
        self.scheduleStatusSecondaryText = scheduleStatusSecondaryText
        self.hourlySlotBackground = hourlySlotBackground
        self.captionOnPhoto = captionOnPhoto
        self.cardShadow = cardShadow
        self.chipBackgroundUnselected = chipBackgroundUnselected
    }

    /// 現行 UI（ダーク）
    static let dark = DetailCardPalette(
        text: Color.white.opacity(0.92),
        secondaryText: Color.white.opacity(0.58),
        accent: Color(red: 0.25, green: 0.82, blue: 0.95),
        iconAccent: Color(red: 1.0, green: 0.62, blue: 0.38),
        warning: Color.orange,
        cardBackground: Color(red: 0.08, green: 0.11, blue: 0.16).opacity(0.90),
        cardBorder: Color.white.opacity(0.12),
        noticeBackground: Color.orange.opacity(0.18),
        bannerBackground: Color(red: 0.25, green: 0.82, blue: 0.95).opacity(0.14),
        scheduleStatusBackground: Color(red: 0.34, green: 0.22, blue: 0.10),
        scheduleStatusBorder: Color(red: 1.0, green: 0.62, blue: 0.22).opacity(0.65),
        scheduleStatusSecondaryText: Color.white.opacity(0.78),
        hourlySlotBackground: Color.white.opacity(0.08),
        captionOnPhoto: Color.white.opacity(0.75),
        cardShadow: Color.black.opacity(0.30),
        chipBackgroundUnselected: Color.white.opacity(0.10)
    )

    /// ライト（レイアウトは同じ、配色のみ反転）
    static let light = DetailCardPalette(
        text: Color(red: 0.10, green: 0.12, blue: 0.16).opacity(0.92),
        secondaryText: Color(red: 0.10, green: 0.12, blue: 0.16).opacity(0.58),
        accent: Color(red: 0.05, green: 0.55, blue: 0.68),
        iconAccent: Color(red: 0.90, green: 0.45, blue: 0.18),
        warning: Color.orange,
        cardBackground: Color.white.opacity(0.92),
        cardBorder: Color.black.opacity(0.10),
        noticeBackground: Color.orange.opacity(0.14),
        bannerBackground: Color(red: 0.05, green: 0.55, blue: 0.68).opacity(0.12),
        scheduleStatusBackground: Color(red: 1.0, green: 0.93, blue: 0.78),
        scheduleStatusBorder: Color(red: 0.82, green: 0.48, blue: 0.04).opacity(0.45),
        scheduleStatusSecondaryText: Color(red: 0.28, green: 0.20, blue: 0.10).opacity(0.78),
        hourlySlotBackground: Color.black.opacity(0.05),
        captionOnPhoto: Color.white.opacity(0.88),
        cardShadow: Color.black.opacity(0.12),
        chipBackgroundUnselected: Color.black.opacity(0.06)
    )
}

private struct DetailCardPaletteKey: EnvironmentKey {
    static let defaultValue = DetailCardPalette.dark
}

extension EnvironmentValues {
    var detailPalette: DetailCardPalette {
        get { self[DetailCardPaletteKey.self] }
        set { self[DetailCardPaletteKey.self] = newValue }
    }
}
