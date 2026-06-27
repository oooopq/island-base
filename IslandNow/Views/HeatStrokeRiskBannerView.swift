//
//  HeatStrokeRiskBannerView.swift
//  Island Now
//
//  WBGT リスク表示（数値と色のみ、説明文なし）
//

import SwiftUI

struct HeatStrokeRiskBannerView: View {
    let risk: HeatStrokeRiskInfo

    @Environment(\.detailPalette) private var palette

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                if let currentWBGT = risk.currentWBGT, let currentLevel = risk.currentLevel {
                    wbgtBadge(value: currentWBGT, level: currentLevel, size: .large)
                        .accessibilityLabel("現在のWBGT \(formatted(currentWBGT))")
                }

                riskScaleBar(activeLevel: risk.currentLevel ?? risk.todayMaxLevel)

                wbgtBadge(value: risk.todayMaxWBGT, level: risk.todayMaxLevel, size: .medium)
                    .accessibilityLabel("今日の最高WBGT \(formatted(risk.todayMaxWBGT))")
            }

            HStack(spacing: 0) {
                ForEach(WBGTRiskLevel.allCases, id: \.self) { level in
                    Rectangle()
                        .fill(level.color)
                        .frame(height: 6)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 3))
            .accessibilityHidden(true)
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(palette.noticeBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    @ViewBuilder
    private func wbgtBadge(value: Double, level: WBGTRiskLevel, size: BadgeSize) -> some View {
        Text(formatted(value))
            .font(size.font)
            .fontWeight(.bold)
            .monospacedDigit()
            .foregroundStyle(palette.text)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(level.color.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func riskScaleBar(activeLevel: WBGTRiskLevel) -> some View {
        HStack(spacing: 4) {
            ForEach(WBGTRiskLevel.allCases, id: \.self) { level in
                Circle()
                    .fill(level.color)
                    .frame(width: level == activeLevel ? 14 : 8, height: level == activeLevel ? 14 : 8)
                    .overlay {
                        if level == activeLevel {
                            Circle()
                                .stroke(palette.text.opacity(0.35), lineWidth: 1.5)
                        }
                    }
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityHidden(true)
    }

    private func formatted(_ value: Double) -> String {
        if value.truncatingRemainder(dividingBy: 1) == 0 {
            return String(format: "%.0f", value)
        }
        return String(format: "%.1f", value)
    }

    private enum BadgeSize {
        case large
        case medium

        var font: Font {
            switch self {
            case .large:
                return .system(size: 34, weight: .bold)
            case .medium:
                return .title2
            }
        }

        var horizontalPadding: CGFloat {
            switch self {
            case .large:
                return 14
            case .medium:
                return 10
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .large:
                return 10
            case .medium:
                return 8
            }
        }
    }
}

#Preview {
    HeatStrokeRiskBannerView(
        risk: HeatStrokeRiskInfo(currentWBGT: 26.0, todayMaxWBGT: 31.0)
    )
    .padding()
    .environment(\.detailPalette, .dark)
}
