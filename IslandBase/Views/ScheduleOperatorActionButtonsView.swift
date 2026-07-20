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
        var actions: [ScheduleOperatorAction] = []

        if let statusURL = company.statusPageLink {
            actions.append(
                ScheduleOperatorAction(
                    id: "status-\(company.name)",
                    title: FerryLinkKind.status.title(for: language),
                    systemImage: "exclamationmark.triangle.fill",
                    url: statusURL,
                    isEmphasized: true
                )
            )
        }

        if let websiteURL = company.websiteLink {
            actions.append(
                ScheduleOperatorAction(
                    id: "schedule-\(company.name)",
                    title: AppText.timetable.string(for: language),
                    systemImage: "calendar",
                    url: websiteURL
                )
            )
        }

        if let phoneURL = company.phoneURL {
            actions.append(
                ScheduleOperatorAction(
                    id: "phone-\(company.name)",
                    title: AppText.phone.string(for: language),
                    systemImage: "phone.fill",
                    url: phoneURL
                )
            )
        }

        return actions
    }

    static func actions(
        for airline: FlightAirline,
        language: AppLanguageMode = .japanese
    ) -> [ScheduleOperatorAction] {
        var actions: [ScheduleOperatorAction] = []

        if let statusURL = airline.statusPageLink {
            actions.append(
                ScheduleOperatorAction(
                    id: "status-\(airline.name)",
                    title: FerryLinkKind.status.title(for: language),
                    systemImage: "exclamationmark.triangle.fill",
                    url: statusURL,
                    isEmphasized: true
                )
            )
        }

        if let websiteURL = airline.websiteLink {
            actions.append(
                ScheduleOperatorAction(
                    id: "schedule-\(airline.name)",
                    title: AppText.timetable.string(for: language),
                    systemImage: "calendar",
                    url: websiteURL
                )
            )
        }

        if let phoneURL = airline.phoneURL {
            actions.append(
                ScheduleOperatorAction(
                    id: "phone-\(airline.name)",
                    title: AppText.phone.string(for: language),
                    systemImage: "phone.fill",
                    url: phoneURL
                )
            )
        }

        return actions
    }

    static func actions(
        for button: FerryLinkButton,
        language: AppLanguageMode = .japanese
    ) -> ScheduleOperatorAction {
        ScheduleOperatorAction(
            id: button.id,
            title: button.kind.title(for: language),
            systemImage: button.kind.systemImage,
            url: button.url,
            isEmphasized: button.kind == .status
        )
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
