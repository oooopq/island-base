//
//  ScheduleOperatorActionButtonsView.swift
//  Island Base
//
//  運航会社・航空会社の公式リンクを横並びアイコンで表示
//

import SwiftUI

struct ScheduleOperatorAction: Identifiable {
    let id: String
    let title: String
    let systemImage: String
    let url: URL
    var isEmphasized: Bool = false
}

struct ScheduleOperatorActionButtonsView: View {
    let actions: [ScheduleOperatorAction]

    @Environment(\.detailPalette) private var palette

    var body: some View {
        if actions.isEmpty == false {
            HStack(spacing: 8) {
                ForEach(actions) { action in
                    actionButton(action)
                }
            }
        }
    }

    @ViewBuilder
    private func actionButton(_ action: ScheduleOperatorAction) -> some View {
        OpenURLButton(url: action.url) {
            VStack(spacing: 4) {
                Image(systemName: action.systemImage)
                    .font(.body)
                    .fontWeight(.semibold)

                Text(action.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
            }
            .foregroundStyle(action.isEmphasized ? palette.warning : palette.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 6)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(action.isEmphasized ? palette.noticeBackground : palette.chipBackground(isSelected: false))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(
                        action.isEmphasized ? palette.warning.opacity(0.45) : palette.cardBorder,
                        lineWidth: 1
                    )
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(action.title)
    }
}

enum ScheduleOperatorActionFactory {
    static func actions(
        for company: FerryCompany,
        language: AppLanguageMode = .japanese
    ) -> [ScheduleOperatorAction] {
        actions(
            idSuffix: company.name,
            statusURL: company.statusPageLink,
            timetableURL: company.websiteLink,
            homeURL: company.homePageLink,
            phoneURL: company.phoneURL,
            language: language
        )
    }

    static func actions(
        for airline: FlightAirline,
        language: AppLanguageMode = .japanese
    ) -> [ScheduleOperatorAction] {
        // 航空会社には公式サイト（トップ）の URL を持たせていない
        actions(
            idSuffix: airline.name,
            statusURL: airline.statusPageLink,
            timetableURL: airline.websiteLink,
            homeURL: nil,
            phoneURL: airline.phoneURL,
            language: language
        )
    }

    /// 公式ボタンを「運航状況 → 時刻表 → 公式サイト → 電話」の順に並べる。
    /// URL が無いボタンは出さない。同じ URL が重なったら、左（優先度の高いほう）だけ残す。
    static func actions(
        idSuffix: String,
        statusURL: URL?,
        timetableURL: URL?,
        homeURL: URL?,
        phoneURL: URL?,
        language: AppLanguageMode = .japanese
    ) -> [ScheduleOperatorAction] {
        var actions: [ScheduleOperatorAction] = []
        var seenURLs = Set<String>()

        func append(_ idPrefix: String, title: String, systemImage: String, url: URL?, isEmphasized: Bool = false) {
            guard let url else { return }
            guard seenURLs.insert(url.absoluteString.lowercased()).inserted else { return }
            actions.append(
                ScheduleOperatorAction(
                    id: "\(idPrefix)-\(idSuffix)",
                    title: title,
                    systemImage: systemImage,
                    url: url,
                    isEmphasized: isEmphasized
                )
            )
        }

        append(
            "status",
            title: FerryLinkKind.status.title(for: language),
            systemImage: FerryLinkKind.status.systemImage,
            url: statusURL,
            isEmphasized: true
        )
        append(
            "schedule",
            title: FerryLinkKind.schedule.title(for: language),
            systemImage: FerryLinkKind.schedule.systemImage,
            url: timetableURL
        )
        append(
            "home",
            title: FerryLinkKind.home.title(for: language),
            systemImage: FerryLinkKind.home.systemImage,
            url: homeURL
        )
        append(
            "phone",
            title: AppText.phone.string(for: language),
            systemImage: "phone.fill",
            url: phoneURL
        )

        return actions
    }
}

#Preview {
    ScheduleOperatorActionButtonsView(
        actions: ScheduleOperatorActionFactory.actions(
            for: FerryCompany(
                name: "サンプルフェリー",
                websiteURL: "https://example.com",
                phoneNumber: "03-1234-5678",
                statusPageURL: "https://example.com/status"
            )
        )
    )
    .padding()
    .detailSectionCard()
}
