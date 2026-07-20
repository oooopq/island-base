//
//  ScheduleStatusCalloutStyle.swift
//  Island Base
//
//  欠航・遅延確認 UI 共通スタイル（ライト/ダーク対応）
//

import SwiftUI

struct ScheduleStatusCalloutStyle: ViewModifier {
    @Environment(\.detailPalette) private var palette

    func body(content: Content) -> some View {
        content
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(palette.text)
            .tint(palette.warning)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.scheduleStatusBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(palette.scheduleStatusBorder, lineWidth: 1.5)
                    }
            }
    }
}

private struct ScheduleStatusSecondaryTextModifier: ViewModifier {
    @Environment(\.detailPalette) private var palette

    func body(content: Content) -> some View {
        content.foregroundStyle(palette.scheduleStatusSecondaryText)
    }
}

extension View {
    func scheduleStatusCallout() -> some View {
        modifier(ScheduleStatusCalloutStyle())
    }

    func scheduleStatusSecondaryText() -> some View {
        modifier(ScheduleStatusSecondaryTextModifier())
    }
}
