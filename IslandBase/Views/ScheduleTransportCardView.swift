//
//  ScheduleTransportCardView.swift
//  Island Base
//
//  ダイヤ画面の交通手段カード
//

import SwiftUI

struct ScheduleTransportCardView<Content: View>: View {
    let kind: ScheduleTransportCardKind
    let tripCount: Int
    @Binding var isExpanded: Bool
    @ViewBuilder let content: () -> Content

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            } label: {
                cardHeader
            }
            .buttonStyle(.plain)

            if isExpanded {
                content()
            }
        }
        .padding(12)
        .background(palette.bannerBackground)
        .overlay {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(kind.accentColor.opacity(0.35), lineWidth: 1)
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private var cardHeader: some View {
        HStack(spacing: 12) {
            Image(systemName: kind.systemImage)
                .font(.title2)
                .foregroundStyle(kind.accentColor)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 3) {
                Text(kind.title(for: languageStore.mode))
                    .font(.headline)
                    .foregroundStyle(palette.text)

                Text(kind.description(for: languageStore.mode))
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText)
            }

            Spacer(minLength: 8)

            VStack(alignment: .trailing, spacing: 4) {
                Text(tripCountText)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(kind.accentColor)

                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.secondaryText)
            }
        }
    }

    private var tripCountText: String {
        languageStore.mode.isJapanese ? "全\(tripCount)便" : "\(tripCount) trips"
    }
}

enum ScheduleTransportCardKind {
    case ferry
    case flight

    var systemImage: String {
        switch self {
        case .ferry:
            return "ferry.fill"
        case .flight:
            return "airplane"
        }
    }

    var accentColor: Color {
        switch self {
        case .ferry:
            return Color(red: 0.12, green: 0.48, blue: 0.88)
        case .flight:
            return Color(red: 0.18, green: 0.62, blue: 0.35)
        }
    }

    func title(for language: AppLanguageMode) -> String {
        switch (self, language) {
        case (.ferry, .japanese):
            return "船便"
        case (.ferry, .english):
            return "Ferry"
        case (.flight, .japanese):
            return "航空便"
        case (.flight, .english):
            return "Flight"
        }
    }

    func description(for language: AppLanguageMode) -> String {
        switch (self, language) {
        case (.ferry, .japanese):
            return "フェリー・高速船"
        case (.ferry, .english):
            return "Ferries and high-speed boats"
        case (.flight, .japanese):
            return "飛行機"
        case (.flight, .english):
            return "Air service"
        }
    }
}
