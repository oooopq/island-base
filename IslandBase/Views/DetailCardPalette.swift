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
    let selectedTabFill: Color
    let accentSoft: Color
    let iconAccent: Color
    let warning: Color
    let urgent: Color
    let green: Color
    let flight: Color
    let weatherSun: Color
    let weatherRain: Color
    let weatherSnow: Color
    let weatherStorm: Color
    let weatherCloud: Color
    let background: Color
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
        isSelected ? accentSoft : chipBackgroundUnselected
    }

    func chipForeground(isSelected: Bool) -> Color {
        isSelected ? accent : secondaryText
    }

    private let chipBackgroundUnselected: Color

    init(
        text: Color,
        secondaryText: Color,
        accent: Color,
        selectedTabFill: Color,
        accentSoft: Color,
        iconAccent: Color,
        warning: Color,
        urgent: Color,
        green: Color,
        flight: Color,
        weatherSun: Color,
        weatherRain: Color,
        weatherSnow: Color,
        weatherStorm: Color,
        weatherCloud: Color,
        background: Color,
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
        self.selectedTabFill = selectedTabFill
        self.accentSoft = accentSoft
        self.iconAccent = iconAccent
        self.warning = warning
        self.urgent = urgent
        self.green = green
        self.flight = flight
        self.weatherSun = weatherSun
        self.weatherRain = weatherRain
        self.weatherSnow = weatherSnow
        self.weatherStorm = weatherStorm
        self.weatherCloud = weatherCloud
        self.background = background
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

    /// ダークモード
    static let dark = DetailCardPalette(
        text: Color(hex: 0xF2F2F7),
        secondaryText: Color(hex: 0x98989F),
        accent: Color(hex: 0x7FBDB7),
        selectedTabFill: Color(hex: 0x3A7D78),
        accentSoft: Color(hex: 0x1F3331),
        iconAccent: Color(hex: 0x7FBDB7),
        warning: Color(hex: 0xD6B46A),
        urgent: Color(hex: 0xE5837A),
        green: Color(hex: 0x78B992),
        flight: Color(hex: 0x93A9C2),
        weatherSun: Color(hex: 0xE0B15E),
        weatherRain: Color(hex: 0x93A9C2),
        weatherSnow: Color(hex: 0x93B3B8),
        weatherStorm: Color(hex: 0xA19BB8),
        weatherCloud: Color(hex: 0xA0A4AA),
        background: Color(hex: 0x000000),
        cardBackground: Color(hex: 0x1C1C1E, opacity: 0.92),
        cardBorder: Color(hex: 0x38383A),
        noticeBackground: Color(hex: 0x2A2418),
        bannerBackground: Color(hex: 0x1A2726),
        scheduleStatusBackground: Color(hex: 0x2A2418),
        scheduleStatusBorder: Color(hex: 0x5C4C2C),
        scheduleStatusSecondaryText: Color(hex: 0x98989F),
        hourlySlotBackground: Color.white.opacity(0.07),
        captionOnPhoto: Color.white.opacity(0.78),
        cardShadow: Color.black.opacity(0.24),
        chipBackgroundUnselected: Color.white.opacity(0.08)
    )

    /// ライトモード
    static let light = DetailCardPalette(
        text: Color(hex: 0x1C1C1E),
        secondaryText: Color(hex: 0x6C6C70),
        accent: Color(hex: 0x2E7572),
        selectedTabFill: Color(hex: 0x2E7572),
        accentSoft: Color(hex: 0xE5F0EE),
        iconAccent: Color(hex: 0x2E7572),
        warning: Color(hex: 0x8F6A1F),
        urgent: Color(hex: 0xB4473D),
        green: Color(hex: 0x3D7F57),
        flight: Color(hex: 0x56708C),
        weatherSun: Color(hex: 0xC08A2E),
        weatherRain: Color(hex: 0x56708C),
        weatherSnow: Color(hex: 0x5F8287),
        weatherStorm: Color(hex: 0x6B6580),
        weatherCloud: Color(hex: 0x7A7D82),
        background: Color(hex: 0xF2F2F7),
        cardBackground: Color(hex: 0xFFFFFF, opacity: 0.94),
        cardBorder: Color(hex: 0xE5E5EA),
        noticeBackground: Color(hex: 0xFAF4E6),
        bannerBackground: Color(hex: 0xEEF5F4),
        scheduleStatusBackground: Color(hex: 0xFAF4E6),
        scheduleStatusBorder: Color(hex: 0xE8D6AE),
        scheduleStatusSecondaryText: Color(hex: 0x6C6C70),
        hourlySlotBackground: Color.black.opacity(0.04),
        captionOnPhoto: Color.white.opacity(0.88),
        cardShadow: Color.black.opacity(0.06),
        chipBackgroundUnselected: Color.black.opacity(0.05)
    )
}

private extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
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
