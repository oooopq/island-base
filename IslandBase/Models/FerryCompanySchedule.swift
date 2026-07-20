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

    init(
        id: String,
        company: FerryCompany,
        trips: [FerryTrip],
        serviceKind: FerryServiceKind? = nil
    ) {
        self.id = id
        self.company = company
        self.trips = trips
        self.serviceKind = serviceKind
    }
}
