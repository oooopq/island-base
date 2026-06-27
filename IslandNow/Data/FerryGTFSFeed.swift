//
//  FerryGTFSFeed.swift
//  Island Now
//
//  GTFS フェリーダイヤの取得先（地域ごとに Feed を定義して IslandProfile へ渡す）
//

import Foundation

struct FerryGTFSFeed: Sendable {
    let id: String
    let downloadURL: URL
    let company: FerryCompany
}

enum FerryGTFSFeedCatalog {
    private static let ottopBase = "https://api3.ottop.org/download/gtfs/ooXuXei4op7y"

    static let anei = FerryGTFSFeed(
        id: "4360002020964",
        downloadURL: URL(string: "\(ottopBase)/4360002020964")!,
        company: FerryCompany(
            name: "安栄観光株式会社",
            websiteURL: "https://www.anei-kanko.co.jp/",
            phoneNumber: "0980-82-4001"
        )
    )

    static let yaeyamaFerry = FerryGTFSFeed(
        id: "6360001013190",
        downloadURL: URL(string: "\(ottopBase)/6360001013190")!,
        company: FerryCompany(
            name: "株式会社八重山観光フェリー",
            websiteURL: "https://www.yaeyamaferry.co.jp/",
            phoneNumber: "0570-013-007"
        )
    )

    static let fukuyama = FerryGTFSFeed(
        id: "5360003005096",
        downloadURL: URL(string: "\(ottopBase)/5360003005096")!,
        company: FerryCompany(
            name: "福山海運株式会社",
            websiteURL: "https://www.fukushimakaiun.com/",
            phoneNumber: "0980-82-5011"
        )
    )
}
