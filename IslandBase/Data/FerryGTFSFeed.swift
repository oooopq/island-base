//
//  FerryGTFSFeed.swift
//  Island Base
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
            websiteURL: "https://aneikankou.co.jp/",
            phoneNumber: "0980-83-0055",
            statusPageURL: "https://aneikankou.co.jp/condition"
        )
    )

    static let yaeyamaFerry = FerryGTFSFeed(
        id: "6360001013190",
        downloadURL: URL(string: "\(ottopBase)/6360001013190")!,
        company: FerryCompany(
            name: "株式会社八重山観光フェリー",
            websiteURL: "https://yaeyama.co.jp/",
            phoneNumber: "0570-013-007",
            statusPageURL: "https://yaeyama.co.jp/operation.html"
        )
    )

    static let fukuyama = FerryGTFSFeed(
        id: "5360003005096",
        downloadURL: URL(string: "\(ottopBase)/5360003005096")!,
        company: FerryCompany(
            name: "福山海運株式会社",
            websiteURL: "https://www.yonakuni-ferry.com/",
            phoneNumber: "0980-87-2555",
            statusPageURL: "https://www.yonakuni-ferry.com/"
        )
    )
}
