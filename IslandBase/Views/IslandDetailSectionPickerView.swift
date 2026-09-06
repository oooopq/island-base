//
//  IslandDetailSectionPickerView.swift
//  Island Base
//
//  島詳細画面のセクション切り替え（アイコン）
//

import SwiftUI

struct IslandDetailSectionPickerView: View {
    @Binding var selection: IslandDetailSection

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
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
        .frame(maxWidth: .infinity)
        .background { pickerBackground }
    }

    @ViewBuilder
    private var pickerBackground: some View {
        if isLightStyle {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(Color(uiColor: .systemGray6))
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.regularMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(Self.lightPickerBorder, lineWidth: 1)
                }
                .shadow(color: palette.cardShadow, radius: 8, y: 3)
        } else {
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .fill(palette.cardBackground.opacity(0.72))
                .background {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .fill(.ultraThinMaterial)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .strokeBorder(palette.cardBorder, lineWidth: 1)
                }
                .shadow(color: palette.cardShadow, radius: 12, y: 5)
        }
    }

    /// Light Mode タブグループ外周（neutral）
    private static let lightPickerBorder = Color.black.opacity(0.10)

    private func sectionButton(_ section: IslandDetailSection) -> some View {
        let isSelected = selection == section

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
                            isSelected
                                ? Color.white
                                : unselectedIconPrimaryColor(section: section),
                            isSelected
                                ? Color.white.opacity(0.82)
                                : unselectedIconSecondaryColor(section: section)
                        )
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                }
                .frame(height: 34)

                Text(section.title(for: languageStore.mode))
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
        .accessibilityLabel(section.title(for: languageStore.mode))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func tabBackground(section: IslandDetailSection, isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(section.resolvedTabGradient(isLightMode: isLightStyle))
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(isLightStyle ? 0.48 : 0.36), lineWidth: 1)
                }
                .shadow(
                    color: section.resolvedIconColor(isLightMode: isLightStyle).opacity(isLightStyle ? 0.46 : 0.58),
                    radius: isLightStyle ? 5 : 6,
                    y: 2
                )
                .matchedGeometryEffect(id: "sectionTabPill", in: selectionNamespace)
        } else if isLightStyle {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(IslandDetailSection.lightUnselectedSurface)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(section.lightModeUnselectedCategoryTint())
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(IslandDetailSection.lightUnselectedBorder, lineWidth: 1)
                }
        } else {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.hourlySlotBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(section.darkModeUnselectedTabBackground())
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(section.darkModeUnselectedTabBorder(), lineWidth: 1)
                }
        }
    }

    private func iconCircleFill(section: IslandDetailSection, isSelected: Bool) -> AnyShapeStyle {
        if isSelected {
            return AnyShapeStyle(Color.white.opacity(isLightStyle ? 0.34 : 0.26))
        }
        if isLightStyle {
            return AnyShapeStyle(section.lightModeUnselectedIconCircleFill())
        }
        return AnyShapeStyle(section.darkModeUnselectedIconCircleFill())
    }

    private func labelColor(section: IslandDetailSection, isSelected: Bool) -> Color {
        if isSelected {
            return Color.white
        }
        if isLightStyle {
            return section.lightModeUnselectedForegroundColor()
        }
        return section.darkModeUnselectedForegroundColor()
    }

    private func unselectedIconPrimaryColor(section: IslandDetailSection) -> Color {
        if isLightStyle {
            return section.lightModeUnselectedForegroundColor()
        }
        return section.darkModeUnselectedForegroundColor()
    }

    private func unselectedIconSecondaryColor(section: IslandDetailSection) -> Color {
        if isLightStyle {
            return section.lightModeUnselectedIconSecondaryColor()
        }
        return section.darkModeUnselectedIconSecondaryColor()
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
        .environment(AppLanguageStore())
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
