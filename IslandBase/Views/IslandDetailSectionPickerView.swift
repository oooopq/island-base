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
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(palette.cardBackground)
            .overlay {
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(palette.cardBorder, lineWidth: 1)
            }
            .shadow(color: palette.cardShadow, radius: 6, y: 2)
    }

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
                        .fill(iconCircleFill(isSelected: isSelected))
                        .frame(width: 34, height: 34)

                    Image(systemName: section.systemImage)
                        .font(.system(size: 16, weight: .bold))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(
                            isSelected
                                ? Color.white
                                : palette.secondaryText,
                            isSelected
                                ? Color.white.opacity(0.82)
                                : palette.secondaryText.opacity(0.65)
                        )
                        .scaleEffect(isSelected ? 1.08 : 1.0)
                }
                .frame(height: 34)

                Text(section.title(for: languageStore.mode))
                    .font(.system(size: 10, weight: isSelected ? .bold : .semibold))
                    .foregroundStyle(isSelected ? Color.white : palette.secondaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background {
                tabBackground(isSelected: isSelected)
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(section.title(for: languageStore.mode))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    @ViewBuilder
    private func tabBackground(isSelected: Bool) -> some View {
        if isSelected {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.selectedTabFill)
                .matchedGeometryEffect(id: "sectionTabPill", in: selectionNamespace)
        } else {
            Color.clear
        }
    }

    private func iconCircleFill(isSelected: Bool) -> Color {
        if isSelected {
            return Color.white.opacity(0.20)
        }
        return palette.chipBackground(isSelected: false)
    }
}

#Preview("ダーク") {
    IslandDetailSectionPickerView(selection: .constant(.schedule))
        .padding()
        .background(DetailCardPalette.dark.background)
        .environment(AppLanguageStore())
        .environment(\.detailPalette, DetailCardPalette.dark)
        .preferredColorScheme(.dark)
}

#Preview("ライト") {
    IslandDetailSectionPickerView(selection: .constant(.savedPhotos))
        .padding()
        .background(DetailCardPalette.light.background)
        .environment(AppLanguageStore())
        .environment(\.detailPalette, DetailCardPalette.light)
        .preferredColorScheme(.light)
}
