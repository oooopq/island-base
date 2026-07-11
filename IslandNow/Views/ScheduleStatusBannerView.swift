//
//  ScheduleStatusBannerView.swift
//  Island Now
//
//  欠航・遅延確認の共通バナー
//

import SwiftUI

struct ScheduleStatusBannerView: View {
    let sources: [ScheduleStatusSource]

    @Environment(\.detailPalette) private var palette

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label {
                Text("欠航・遅延")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            } icon: {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(palette.warning)
            }

            Text("出発前に各社公式サイトで運航状況を確認してください。本アプリの時刻は参考ダイヤです。")
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
            Text(source.name)
                .font(.caption)
                .fontWeight(.semibold)

            sourceActionButtons(source)
        }
    }

    @ViewBuilder
    private func sourceActionButtons(_ source: ScheduleStatusSource) -> some View {
        ScheduleOperatorActionButtonsView(actions: actions(for: source))
    }

    private func actions(for source: ScheduleStatusSource) -> [ScheduleOperatorAction] {
        var actions: [ScheduleOperatorAction] = [
            ScheduleOperatorAction(
                id: "status-\(source.id)",
                title: "運航状況",
                systemImage: statusIcon(for: source.category),
                url: source.statusPageURL,
                isEmphasized: true
            ),
        ]

        if let phoneURL = source.phoneURL {
            actions.append(
                ScheduleOperatorAction(
                    id: "phone-\(source.id)",
                    title: "電話",
                    systemImage: "phone.fill",
                    url: phoneURL
                )
            )
        }

        return actions
    }

    private func statusIcon(for category: ScheduleStatusSource.Category) -> String {
        switch category {
        case .ferry:
            return "ferry.fill"
        case .flight:
            return "airplane"
        }
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
