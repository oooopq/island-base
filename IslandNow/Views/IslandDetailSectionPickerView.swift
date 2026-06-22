//
//  IslandDetailSectionPickerView.swift
//  Island Now
//
//  島詳細画面のセクション切り替え（アイコン）
//

import SwiftUI

struct IslandDetailSectionPickerView: View {
    @Binding var selection: IslandDetailSection

    var body: some View {
        HStack(spacing: 8) {
            ForEach(IslandDetailSection.allCases) { section in
                sectionButton(section)
            }
        }
        .padding(8)
        .background {
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(DetailCardTheme.cardBackground)
                .overlay {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(DetailCardTheme.cardBorder, lineWidth: 1)
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
                Text(section.title)
                    .font(.caption2)
                    .fontWeight(.medium)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .foregroundStyle(isSelected ? DetailCardTheme.accent : DetailCardTheme.secondaryText)
            .background {
                if isSelected {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(DetailCardTheme.accent.opacity(0.18))
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
