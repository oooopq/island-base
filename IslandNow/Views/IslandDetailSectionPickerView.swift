//
//  IslandDetailSectionPickerView.swift
//  Island Now
//
//  島詳細画面のセクション切り替え（アイコン）
//

import SwiftUI

struct IslandDetailSectionPickerView: View {
    @Binding var selection: IslandDetailSection

    @Environment(\.detailPalette) private var palette
    @Namespace private var selectionNamespace

    /// ライトモードは背景写真の上でも読みやすい配色に切り替える
    private var isLightStyle: Bool {
        palette == DetailCardPalette.light
    }

    var body: some View {
        HStack(spacing: 4) {
            ForEach(IslandDetailSection.allCases) { section in
                sectionButton(section)
            }
        }
        .padding(5)
        .background { pickerBackground }
    }

    @ViewBuilder
    private var pickerBackground: some View {
        if isLightStyle {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color.white.opacity(0.96))
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.regularMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(lightModePickerBorderGradient, lineWidth: 1.5)
                }
                .shadow(color: palette.cardShadow, radius: 10, y: 4)
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.cardBackground.opacity(0.72))
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(rainbowBorderGradient, lineWidth: 1.5)
                }
                .shadow(color: palette.cardShadow, radius: 12, y: 5)
        }
    }

    private var rainbowBorderGradient: LinearGradient {
        LinearGradient(
            colors: IslandDetailSection.allCases.map(\.iconColor),
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private var lightModePickerBorderGradient: LinearGradient {
        LinearGradient(
            colors: IslandDetailSection.allCases.map { $0.resolvedIconColor(isLightMode: true) },
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    private func sectionButton(_ section: IslandDetailSection) -> some View {
        let isSelected = selection == section
        let iconColor = section.resolvedIconColor(isLightMode: isLightStyle)

        return Button {
            withAnimation(.spring(response: 0.34, dampingFraction: 0.78)) {
                selection = section
            }
        } label: {
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(iconCircleFill(section: section, isSelected: isSelected))
                        .frame(width: 34, height: 34)

                    Image(systemName: section.systemImage)
                        .font(.system(size: 16, weight: .bold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            isSelected ? Color.white : iconColor,
                            isSelected
                                ? Color.white.opacity(0.75)
                                : section.unselectedIconSecondaryColor(isLightMode: isLightStyle)
                        )
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                }
                .frame(height: 34)

                Text(section.title)
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(labelColor(section: section, isSelected: isSelected))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                tabBackground(section: section, isSelected: isSelected)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(section.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func tabBackground(section: IslandDetailSection, isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(section.resolvedTabGradient(isLightMode: isLightStyle))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(isLightStyle ? 0.35 : 0.28), lineWidth: 1)
                }
                .shadow(
                    color: section.resolvedIconColor(isLightMode: isLightStyle).opacity(isLightStyle ? 0.38 : 0.55),
                    radius: 8,
                    y: 3
                )
                .matchedGeometryEffect(id: "sectionTabPill", in: selectionNamespace)
        } else if isLightStyle {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(section.unselectedTabBackground(isLightMode: true))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(
                            section.unselectedTabBorder(isLightMode: true),
                            lineWidth: 1.25
                        )
                }
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(section.iconColor.opacity(0.12))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(section.iconColor.opacity(0.28), lineWidth: 1)
                }
        }
    }

    private func iconCircleFill(section: IslandDetailSection, isSelected: Bool) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(Color.white.opacity(isLightStyle ? 0.28 : 0.22))
        }
        return AnyShapeStyle(section.unselectedIconCircleFill(isLightMode: isLightStyle))
    }

    private func labelColor(section: IslandDetailSection, isSelected: Bool) -> Color {
        if isSelected {
            return Color.white
        }
        if isLightStyle {
            return section.resolvedIconColor(isLightMode: true)
        }
        return section.iconColor.opacity(0.92)
    }
}

#Preview("ダーク") {
    IslandDetailSectionPickerView(selection: .constant(.schedule))
        .padding()
        .background {
            LinearGradient(
                colors: [Color(red: 0.05, green: 0.18, blue: 0.32), Color(red: 0.02, green: 0.08, blue: 0.16)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .environment(\.detailPalette, DetailCardPalette.dark)
        .preferredColorScheme(.dark)
}

#Preview("ライト") {
    IslandDetailSectionPickerView(selection: .constant(.savedPhotos))
        .padding()
        .background {
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.78, blue: 0.95),
                    Color(red: 0.88, green: 0.94, blue: 0.98),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .environment(\.detailPalette, DetailCardPalette.light)
        .preferredColorScheme(.light)
}
