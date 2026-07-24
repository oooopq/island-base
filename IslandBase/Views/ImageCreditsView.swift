//
//  ImageCreditsView.swift
//  Island Base
//
//  背景画像・データ出典・規約リンク（公開・法務向け）
//

import SwiftUI

struct ImageCreditsView: View {
    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

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
        .navigationTitle(languageStore.t(.creditsAndSources))
        .navigationBarTitleDisplayMode(.inline)
    }

    private var introSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(introBody)
                .font(.subheadline)
                .foregroundStyle(palette.text)

            Text(introNote)
                .font(.caption)
                .foregroundStyle(palette.secondaryText)
        }
        .creditCardStyle(palette: palette)
    }

    // 天気・波・船便・店舗などのデータ提供元
    private var dataSourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(sectionTitleData)
                .font(.headline)
                .foregroundStyle(palette.text)

            dataSourceCard(
                title: weatherTitle,
                credit: "Weather data by Open-Meteo.com",
                note: weatherNote,
                linkTitle: "open-meteo.com",
                urlString: "https://open-meteo.com/"
            )

            dataSourceCard(
                title: ferryTitle,
                credit: ferryCredit,
                note: ferryNote,
                linkTitle: "ottop.org",
                urlString: "https://www.ottop.org/"
            )

            dataSourceCard(
                title: placesTitle,
                credit: placesCredit,
                note: placesNote,
                linkTitle: "Apple Maps / MapKit",
                urlString: "https://www.apple.com/maps/"
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

    // 地域ホームのカバー画像（Unsplash / Wikimedia 等）
    private var regionCoverCreditsSection: some View {
        let regionsWithCredit = IslandRegionCatalog.all.filter { $0.coverAssetCredit != nil }
        return VStack(alignment: .leading, spacing: 12) {
            Text(sectionTitleRegionCovers)
                .font(.headline)
                .foregroundStyle(palette.text)

            ForEach(regionsWithCredit) { region in
                VStack(alignment: .leading, spacing: 6) {
                    Text(region.displayName(for: languageStore.mode))
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
            Text(sectionTitleIslandBackgrounds)
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
            Text(sectionTitleLegal)
                .font(.headline)
                .foregroundStyle(palette.text)

            VStack(alignment: .leading, spacing: 8) {
                if let url = AppLegalInfo.privacyPolicyURL {
                    legalLinkRow(title: privacyTitle, url: url)
                }
                if let url = AppLegalInfo.termsOfServiceURL {
                    legalLinkRow(title: termsTitle, url: url)
                }
                if let url = AppLegalInfo.supportEmailURL {
                    legalLinkRow(
                        title: "\(contactTitle)（\(AppLegalInfo.supportEmail)）",
                        url: url
                    )
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
            Text(sectionTitleLicense)
                .font(.headline)
                .foregroundStyle(palette.text)

            licenseNote(title: "Unsplash License", body: unsplashBody)
            licenseNote(title: "Wikimedia Commons", body: wikimediaBody)

            VStack(alignment: .leading, spacing: 8) {
                licenseLinkRow(
                    title: "CC BY-SA 1.0",
                    urlString: "https://creativecommons.org/licenses/by-sa/1.0/"
                )
                licenseLinkRow(
                    title: "CC BY-SA 3.0",
                    urlString: "https://creativecommons.org/licenses/by-sa/3.0/"
                )
                licenseLinkRow(
                    title: "CC BY-SA 4.0",
                    urlString: "https://creativecommons.org/licenses/by-sa/4.0/"
                )
                licenseLinkRow(
                    title: "CC BY 3.0",
                    urlString: "https://creativecommons.org/licenses/by/3.0/"
                )
                licenseLinkRow(
                    title: "CC BY 4.0",
                    urlString: "https://creativecommons.org/licenses/by/4.0/"
                )
            }
            .creditCardStyle(palette: palette)

            licenseNote(title: gsiTitle, body: gsiBody)
            licenseNote(title: providedPhotoTitle, body: providedPhotoBody)
            licenseNote(title: photoNotesTitle, body: photoNotesBody)
            licenseNote(title: appIconTitle, body: appIconBody)
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

    // MARK: - 表示文言（日英）

    private var isJapanese: Bool { languageStore.mode.isJapanese }

    private var introBody: String {
        isJapanese
            ? "このアプリでは、天気・波の高さ・船便ダイヤ・店舗情報などのデータと、各島の背景画像を、以下の提供元から利用しています。"
            : "This app uses weather, wave height, ferry timetables, place data, and island background images from the sources below."
    }

    private var introNote: String {
        isJapanese
            ? "出典表記は各提供元のライセンス・利用条件に従います。"
            : "Attribution follows each provider’s license and terms."
    }

    private var sectionTitleData: String {
        isJapanese ? "データの出典" : "Data sources"
    }

    private var weatherTitle: String {
        isJapanese ? "天気・波の高さ" : "Weather & wave height"
    }

    private var weatherNote: String {
        isJapanese
            ? "Open-Meteo の天気・海洋データ（CC BY 4.0 ライセンス）を利用しています。"
            : "Uses Open-Meteo weather and marine data (CC BY 4.0)."
    }

    private var ferryTitle: String {
        isJapanese ? "船便ダイヤ" : "Ferry timetables"
    }

    private var ferryCredit: String {
        isJapanese
            ? "八重山のGTFSダイヤ提供：特定非営利活動法人OTTOP（沖縄県の公共交通オープンデータ）"
            : "Yaeyama GTFS timetables: NPO OTTOP (Okinawa public transit open data)"
    }

    private var ferryNote: String {
        isJapanese
            ? "八重山以外の地域は、各運航会社の公式サイトへのリンクのみです。時刻表はアプリ内に表示しません。最新の運航状況は各運航会社の公式サイトでご確認ください。"
            : "Outside Yaeyama, the app links to each operator’s official site only and does not show in-app timetables. Always check the operator’s site for the latest status."
    }

    private var placesTitle: String {
        isJapanese ? "店舗・スポット" : "Places"
    }

    private var placesCredit: String {
        isJapanese
            ? "島付近の飲食店・宿・商店などの検索結果は Apple マップ（MapKit）のデータを表示しています。"
            : "Nearby restaurants, lodging, and shops come from Apple Maps (MapKit)."
    }

    private var placesNote: String {
        isJapanese
            ? "営業時間・休業・存在の正確性は保証しません。詳細は Apple マップまたは各店舗でご確認ください。"
            : "Hours, closures, and accuracy are not guaranteed. Confirm in Apple Maps or with the business."
    }

    private var sectionTitleRegionCovers: String {
        isJapanese ? "地域カバー画像" : "Region cover images"
    }

    private var sectionTitleIslandBackgrounds: String {
        isJapanese ? "島別の背景画像" : "Island background images"
    }

    private var sectionTitleLicense: String {
        isJapanese ? "ライセンスについて" : "Licenses"
    }

    private var sectionTitleLegal: String {
        isJapanese ? "アプリの規約・お問い合わせ" : "Policies & contact"
    }

    private var privacyTitle: String {
        isJapanese ? "プライバシーポリシー" : "Privacy Policy"
    }

    private var termsTitle: String {
        isJapanese ? "利用規約" : "Terms of Use"
    }

    private var contactTitle: String {
        isJapanese ? "お問い合わせ" : "Contact"
    }

    private var unsplashBody: String {
        isJapanese
            ? "商用・非商用を問わず利用できます。クレジット表示は任意ですが、本アプリでは提供元を明示しています。"
            : "May be used commercially or non-commercially. Credit is optional; this app still shows attribution."
    }

    private var wikimediaBody: String {
        isJapanese
            ? "各画像に記載の Creative Commons ライセンス、Public domain、または出典表示条件に従い、作者名・対象・ライセンスまたは出典を表示しています。背景表示の際、視認性のため画像の上に暗色グラデーションを重ねています（この加工は各島のクレジットに明記しています）。"
            : "Images follow the Creative Commons, public domain, or attribution terms shown for each file. A dark gradient may be overlaid for readability (noted in each island credit)."
    }

    private var gsiTitle: String {
        isJapanese ? "国土地理院" : "Geospatial Information Authority of Japan"
    }

    private var gsiBody: String {
        isJapanese
            ? "二神島・怒和島・津和地島の空中写真は、Wikimedia Commons 経由で国土地理院の出典表示条件に従って利用しています。該当する画像クレジットには「出典：国土地理院」と明記しています。"
            : "Aerial photos of Futagami, Nuwa, and Tsuwaji are used via Wikimedia Commons under GSI attribution rules. Credits include “出典：国土地理院”."
    }

    private var providedPhotoTitle: String {
        isJapanese ? "提供写真" : "Provided photos"
    }

    private var providedPhotoBody: String {
        isJapanese
            ? "黒島・波照間島・八丈島および犬島の背景画像は、提供写真としてクレジットを表示しています。第三者の素材として再配布するものではありません。"
            : "Backgrounds for Kuroshima, Hateruma, Hachijojima, and Inujima are provided photos with credit shown. They are not redistributed as third-party stock."
    }

    private var photoNotesTitle: String {
        isJapanese ? "写真メモ（利用者撮影）" : "Photo notes (user photos)"
    }

    private var photoNotesBody: String {
        isJapanese
            ? "利用者が撮影または選んだ写真は、この端末内だけに保存されます。当方のサーバーへ送信せず、本クレジット一覧の第三者素材には含めません。"
            : "Photos you take or pick are stored only on this device, are not sent to our servers, and are not third-party assets listed here."
    }

    private var appIconTitle: String {
        isJapanese ? "アプリアイコン" : "App icon"
    }

    private var appIconBody: String {
        isJapanese
            ? "Island Base 用のオリジナルデザインです（第三者の画像素材は使用していません）。"
            : "Original design for Island Base (no third-party image assets)."
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
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
