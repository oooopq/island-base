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

    var body: some View {
        HStack(spacing: 8) {
            ForEach(IslandDetailSection.allCases) { section in
                sectionButton(section)
            }
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(palette.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(palette.cardBorder, lineWidth: 1)
                }
        }
    }

    private func sectionButton(_ section: IslandDetailSection) -> some View {
        let isSelected = selection == section

        return Button {
            selection = section
        } label: {
            VStack(spacing: 4) {
                Image(systemName: section.systemImage)
                    .font(.title3)
                    .foregroundStyle(section.iconColor.opacity(isSelected ? 1 : 0.82))
                Text(section.title)
                    .font(.caption2)
                    .fontWeight(.medium)
                    .foregroundStyle(isSelected ? palette.text : palette.secondaryText)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(section.iconColor.opacity(0.22))
                        .overlay {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(section.iconColor.opacity(0.45), lineWidth: 1)
                        }
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(section.title)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    IslandDetailSectionPickerView(selection: .constant(.weather))
        .padding()
        .background(Color.black)
}
