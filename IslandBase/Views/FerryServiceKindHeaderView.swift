//
//  FerryServiceKindHeaderView.swift
//  Island Base
//
//  高速船・夜航客船などの種別ヘッダー
//

import SwiftUI

struct FerryServiceKindHeaderView: View {
    let serviceKind: FerryServiceKind

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: serviceKind.systemImage)
                .font(.title3)
                .foregroundStyle(palette.accent)
                .frame(width: 28)

            VStack(alignment: .leading, spacing: 4) {
                Text(serviceKind.title(for: languageStore.mode))
                    .font(.subheadline)
                    .fontWeight(.semibold)

                Text(serviceKind.description(for: languageStore.mode))
                    .font(.caption)
                    .detailCardSecondaryText()
            }
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(palette.bannerBackground)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

#Preview {
    VStack(spacing: 16) {
        FerryServiceKindHeaderView(serviceKind: .highSpeedBoat)
        FerryServiceKindHeaderView(serviceKind: .overnightFerry)
    }
    .padding()
    .detailSectionCard()
    .environment(AppLanguageStore())
}
