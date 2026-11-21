//
//  ScheduleTransportHeaderView.swift
//  Island Base
//
//  船便 / 航空便セクションの見出し（アイコン＋色分け）
//

import SwiftUI

enum ScheduleTransportKind {
    case ferry
    case flight

    var systemImage: String {
        switch self {
        case .ferry: return "ferry.fill"
        case .flight: return "airplane"
        }
    }

    func accentColor(in palette: DetailCardPalette) -> Color {
        switch self {
        case .ferry:
            return palette.accent
        case .flight:
            return palette.flight
        }
    }
}

struct ScheduleTransportHeaderView: View {
    let kind: ScheduleTransportKind
    let title: String
    var subtitle: String? = nil

    @Environment(\.detailPalette) private var palette

    var body: some View {
        let transportColor = kind.accentColor(in: palette)

        HStack(alignment: .top, spacing: 10) {
            RoundedRectangle(cornerRadius: 1.5, style: .continuous)
                .fill(transportColor)
                .frame(width: 3, height: barHeight)

            VStack(alignment: .leading, spacing: 4) {
                Label(title, systemImage: kind.systemImage)
                    .font(.headline)
                    .foregroundStyle(transportColor)
                    .labelStyle(.titleAndIcon)

                if let subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)
                }
            }
        }
    }

    private var barHeight: CGFloat {
        subtitle == nil ? 22 : 36
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 20) {
        ScheduleTransportHeaderView(
            kind: .ferry,
            title: "船便",
            subtitle: "フェリー・高速船"
        )
        ScheduleTransportHeaderView(
            kind: .flight,
            title: "航空便"
        )
    }
    .padding()
    .environment(\.detailPalette, DetailCardPalette.dark)
}
