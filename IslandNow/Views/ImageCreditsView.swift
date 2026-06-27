//
//  ImageCreditsView.swift
//  Island Now
//
//  背景画像の提供元・ライセンス一覧（公開・法務向け）
//

import SwiftUI

struct ImageCreditsView: View {
    @Environment(\.detailPalette) private var palette

    private var entries: [IslandCatalog.BackgroundCreditEntry] {
        IslandCatalog.backgroundCreditEntries
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                introSection
                dataSourcesSection
                islandCreditsSection
                licenseNotesSection
            }
            .padding(16)
        }
        .background(listBackground)
        .navigationTitle("クレジット・出典")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("このアプリでは、天気・暑さ指数・船便ダイヤなどのデータと、各島の背景画像を、以下の提供元から利用しています。")
                .font(.subheadline)
                .foregroundStyle(palette.text)

            Text("出典表記は各提供元のライセンス・利用条件に従います。")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .creditCardStyle(palette: palette)
    }

    // 天気・WBGT・フェリーダイヤのデータ提供元（各ライセンス・利用規約に基づく出典表記）
    private var dataSourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("データの出典")
                .font(.headline)
                .foregroundStyle(palette.text)

            dataSourceCard(
                title: "天気",
                credit: "Weather data by Open-Meteo.com",
                note: "Open-Meteo の天気データ（CC BY 4.0 ライセンス）を利用しています。",
                linkTitle: "open-meteo.com",
                urlString: "https://open-meteo.com/"
            )

            dataSourceCard(
                title: "暑さ指数（WBGT）",
                credit: "出典：環境省熱中症予防情報サイト",
                note: "夏季（4月下旬〜10月中旬）のみ表示しています。表示は参考情報です。",
                linkTitle: "wbgt.env.go.jp",
                urlString: "https://www.wbgt.env.go.jp/"
            )

            dataSourceCard(
                title: "船便ダイヤ",
                credit: "ダイヤ提供：特定非営利活動法人OTTOP（沖縄県の公共交通オープンデータ）",
                note: "代表的なダイヤの目安です。最新の運航状況は各運航会社の公式サイトでご確認ください。",
                linkTitle: "ottop.org",
                urlString: "https://www.ottop.org/"
            )
        }
    }

    private func dataSourceCard(
        title: String,
        credit: String,
        note: String,
        linkTitle: String,
        urlString: String
    ) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(palette.text)

            Text(credit)
                .font(.caption)
                .foregroundStyle(palette.text)
                .fixedSize(horizontal: false, vertical: true)

            Text(note)
                .font(.caption2)
                .foregroundStyle(palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)

            if let url = AppURL.from(string: urlString) {
                OpenURLButton(url: url) {
                    HStack(spacing: 4) {
                        Image(systemName: "link")
                        Text(linkTitle)
                    }
                    .font(.caption)
                    .foregroundStyle(palette.iconAccent)
                }
            }
        }
        .creditCardStyle(palette: palette)
    }

    private var islandCreditsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("島別の背景画像")
                .font(.headline)
                .foregroundStyle(palette.text)

            ForEach(entries) { entry in
                VStack(alignment: .leading, spacing: 6) {
                    Text(entry.islandNameJapanese)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.text)

                    Text(entry.regionNameJapanese)
                        .font(.caption)
                        .foregroundStyle(palette.secondaryText)

                    Text(entry.credit)
                        .font(.caption)
                        .foregroundStyle(palette.text)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .creditCardStyle(palette: palette)
            }
        }
    }

    private var licenseNotesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("ライセンスについて")
                .font(.headline)
                .foregroundStyle(palette.text)

            licenseNote(
                title: "Unsplash License",
                body: "商用・非商用を問わず利用できます。クレジット表示は任意ですが、本アプリでは提供元を明示しています。"
            )

            licenseNote(
                title: "Wikimedia Commons",
                body: "各画像に記載の Creative Commons ライセンス（CC BY / CC BY-SA など）に従い、作者名とライセンスを表示しています。"
            )

            licenseNote(
                title: "アプリアイコン",
                body: "Island Now 用のオリジナルデザインです（第三者の画像素材は使用していません）。"
            )
        }
    }

    private func licenseNote(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(palette.text)

            Text(body)
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
        }
        .creditCardStyle(palette: palette)
    }

    private var listBackground: some View {
        palette.cardBackground.opacity(0.15)
            .ignoresSafeArea()
    }
}

private extension View {
    func creditCardStyle(palette: DetailCardPalette) -> some View {
        frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(palette.cardBackground)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .strokeBorder(palette.cardBorder, lineWidth: 1)
                    }
            }
    }
}

#Preview {
    NavigationStack {
        ImageCreditsView()
    }
    .environment(AppThemeStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
