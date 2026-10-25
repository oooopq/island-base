//
//  ScheduleStatusBannerView.swift
//  Island Base
//
//  欠航・遅延確認の共通バナー
//

import SwiftUI

struct ScheduleStatusBannerView: View {
    let sources: [ScheduleStatusSource]

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text(languageStore.t(.cancellationsDelays))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(palette.warning)
            }

            Text(languageStore.t(.checkStatusBeforeDeparture))
                .font(.caption)
                .fixedSize(horizontal: false, vertical: true)

            ForEach(sources) { source in
                sourceLinks(source)
            }
        }
        .scheduleStatusCallout()
    }

    @ViewBuilder
    private func sourceLinks(_ source: ScheduleStatusSource) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(source.displayName(for: languageStore.mode))
                .font(.caption)
                .fontWeight(.semibold)

            sourceActionButtons(source)
        }
    }

    @ViewBuilder
    private func sourceActionButtons(_ source: ScheduleStatusSource) -> some View {
        ScheduleOperatorActionButtonsView(actions: actions(for: source))
    }

    // 欠航・遅延枠は「運航状況 / 電話」の2つだけ
    private func actions(for source: ScheduleStatusSource) -> [ScheduleOperatorAction] {
        ScheduleOperatorActionFactory.actions(
            idSuffix: source.id,
            statusURL: source.statusPageURL,
            timetableURL: nil,
            homeURL: nil,
            phoneURL: source.phoneURL,
            language: languageStore.mode
        )
    }
}

#Preview("Dark") {
    ScheduleStatusBannerView(sources: [
        ScheduleStatusSource(
            id: "https://www.tokaikisen.co.jp/schedule/",
            name: "東海汽船株式会社",
            statusPageURL: URL(string: "https://www.tokaikisen.co.jp/schedule/")!,
            phoneNumber: "03-5472-9999",
            category: .ferry
        ),
    ])
    .padding()
    .detailSectionCard()
    .environment(\.detailPalette, .dark)
}

#Preview("Light") {
    ScheduleStatusBannerView(sources: [
        ScheduleStatusSource(
            id: "https://www.tokaikisen.co.jp/schedule/",
            name: "東海汽船株式会社",
            statusPageURL: URL(string: "https://www.tokaikisen.co.jp/schedule/")!,
            phoneNumber: "03-5472-9999",
            category: .ferry
        ),
    ])
    .padding()
    .detailSectionCard()
    .environment(\.detailPalette, .light)
}
