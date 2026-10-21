//
//  FerryCompanySchedule.swift
//  Island Base
//
//  運営会社1社分のフェリーダイヤ
//

import Foundation

struct FerryCompanySchedule: Identifiable, Codable {
    let id: String
    let company: FerryCompany
    let trips: [FerryTrip]
    /// 高速船・夜航客船など（伊豆諸島など複数船種がある路線向け）
    let serviceKind: FerryServiceKind?
    /// 東線・西線など。GTFS 由来では nil
    let lineLabel: String?
    /// Pages JSON の fetchedAt。GTFS 由来では nil
    let sourceUpdatedAt: Date?
    /// nil はボタンを出す（既存ダイヤ）。false のとき会社リンクは時刻表の外に任せる
    let showsOperatorActions: Bool?

    init(
        id: String,
        company: FerryCompany,
        trips: [FerryTrip],
        serviceKind: FerryServiceKind? = nil,
        lineLabel: String? = nil,
        sourceUpdatedAt: Date? = nil,
        showsOperatorActions: Bool? = nil
    ) {
        self.id = id
        self.company = company
        self.trips = trips
        self.serviceKind = serviceKind
        self.lineLabel = lineLabel
        self.sourceUpdatedAt = sourceUpdatedAt
        self.showsOperatorActions = showsOperatorActions
    }
}
