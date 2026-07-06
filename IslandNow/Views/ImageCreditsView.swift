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
                regionCoverCreditsSection
                islandCreditsSection
                licenseNotesSection
                legalLinksSection
            }
            .padding(16)
        }
        .background(listBackground)
        .navigationTitle("クレジット・出典")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("このアプリでは、天気・波の高さ・船便ダイヤなどのデータと、各島の背景画像を、以下の提供元から利用しています。")
                .font(.subheadline)
                .foregroundStyle(palette.text)

            Text("出典表記は各提供元のライセンス・利用条件に従います。")
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .creditCardStyle(palette: palette)
    }

    // 天気・波の高さ・フェリーダイヤのデータ提供元（各ライセンス・利用規約に基づく出典表記）
    private var dataSourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("データの出典")
                .font(.headline)
                .foregroundStyle(palette.text)

            dataSourceCard(
                title: "天気・波の高さ",
                credit: "Weather data by Open-Meteo.com",
                note: "Open-Meteo の天気・海洋データ（CC BY 4.0 ライセンス）を利用しています。",
                linkTitle: "open-meteo.com",
                urlString: "https://open-meteo.com/"
            )

            dataSourceCard(
                title: "船便ダイヤ",
                credit: "八重山のGTFSダイヤ提供：特定非営利活動法人OTTOP（沖縄県の公共交通オープンデータ）",
                note: "八重山以外の地域は、各運航会社の公式サイト・公開情報をもとにした代表ダイヤまたは公式リンクです。最新の運航状況は各運航会社の公式サイトでご確認ください。",
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

    // 地域ホーム画面のカバー画像（Unsplash）の出典一覧
    private var regionCoverCreditsSection: some View {
        let regionsWithCredit = IslandRegionCatalog.all.filter { $0.coverAssetCredit != nil }
        return VStack(alignment: .leading, spacing: 12) {
            Text("地域カバー画像")
                .font(.headline)
                .foregroundStyle(palette.text)

            ForEach(regionsWithCredit) { region in
                VStack(alignment: .leading, spacing: 6) {
                    Text(region.displayNameJapanese)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(palette.text)

                    if let credit = region.coverAssetCredit {
                        Text(credit)
                            .font(.caption)
                            .foregroundStyle(palette.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
                .creditCardStyle(palette: palette)
            }
        }
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

    private var legalLinksSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("アプリの規約・お問い合わせ")
                .font(.headline)
                .foregroundStyle(palette.text)

            VStack(alignment: .leading, spacing: 8) {
                if let url = AppLegalInfo.privacyPolicyURL {
                    legalLinkRow(title: "プライバシーポリシー", url: url)
                }
                if let url = AppLegalInfo.termsOfServiceURL {
                    legalLinkRow(title: "利用規約", url: url)
                }
                if let url = AppLegalInfo.supportEmailURL {
                    legalLinkRow(title: "お問い合わせ（\(AppLegalInfo.supportEmail)）", url: url)
                }
            }
            .creditCardStyle(palette: palette)
        }
    }

    private func legalLinkRow(title: String, url: URL) -> some View {
        OpenURLButton(url: url) {
            HStack(spacing: 6) {
                Image(systemName: "link")
                Text(title)
                    .font(.caption)
            }
            .foregroundStyle(palette.iconAccent)
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
                body: "各画像に記載の Creative Commons ライセンス、Public domain、または出典表示条件に従い、作者名・対象・ライセンスまたは出典を表示しています。背景表示の際、視認性のため画像の上に暗色グラデーションを重ねています（この加工は各島のクレジットに明記しています）。"
            )

            VStack(alignment: .leading, spacing: 8) {
                licenseLinkRow(
                    title: "CC BY-SA 1.0（ライセンス全文）",
                    urlString: "https://creativecommons.org/licenses/by-sa/1.0/"
                )
                licenseLinkRow(
                    title: "CC BY-SA 3.0（ライセンス全文）",
                    urlString: "https://creativecommons.org/licenses/by-sa/3.0/"
                )
                licenseLinkRow(
                    title: "CC BY-SA 4.0（ライセンス全文）",
                    urlString: "https://creativecommons.org/licenses/by-sa/4.0/"
                )
            }
            .creditCardStyle(palette: palette)

            licenseNote(
                title: "国土地理院",
                body: "二神島・怒和島・津和地島の空中写真は、Wikimedia Commons 経由で国土地理院の出典表示条件に従って利用しています。該当する画像クレジットには「出典：国土地理院」と明記しています。"
            )

            licenseNote(
                title: "NASA / Public domain",
                body: "佐渡島・波照間島・五島列島などの一部背景画像は NASA Johnson Space Center の Public domain 画像を利用しています。出典確認のため、クレジットには提供元を明記しています。"
            )

            licenseNote(
                title: "提供写真",
                body: "犬島の背景画像は、提供写真としてクレジットを表示しています。第三者の素材として再配布するものではありません。"
            )

            licenseNote(
                title: "アプリアイコン",
                body: "Island Now 用のオリジナルデザインです（第三者の画像素材は使用していません）。"
            )
        }
    }

    private func licenseLinkRow(title: String, urlString: String) -> some View {
        Group {
            if let url = AppURL.from(string: urlString) {
                OpenURLButton(url: url) {
                    HStack(spacing: 6) {
                        Image(systemName: "link")
                        Text(title)
                            .font(.caption)
                    }
                    .foregroundStyle(palette.iconAccent)
                }
            }
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
