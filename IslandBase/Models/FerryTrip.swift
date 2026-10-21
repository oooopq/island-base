//
//  FerryTrip.swift
//  Island Base
//
//  フェリー1便分の情報
//

import Foundation

struct FerryTrip: Identifiable, Codable {
    let id: String
    let routeName: String
    let departureTime: String
    let arrivalTime: String
    /// 運休などの注記。GTFS 由来の便では nil
    let note: String?
    /// 出発港の島。未設定なら航路名から推定する（八重山 GTFS）
    let departureIslandID: String?
    /// 到着港の島。本島側の港は nil
    let arrivalIslandID: String?

    init(
        id: String,
        routeName: String,
        departureTime: String,
        arrivalTime: String,
        note: String? = nil,
        departureIslandID: String? = nil,
        arrivalIslandID: String? = nil
    ) {
        self.id = id
        self.routeName = routeName
        self.departureTime = departureTime
        self.arrivalTime = arrivalTime
        self.note = note
        self.departureIslandID = departureIslandID
        self.arrivalIslandID = arrivalIslandID
    }

    /// 発着がそろっている便だけ「次の便」や時刻表示に使う
    var hasScheduledTimes: Bool {
        departureTime.isEmpty == false && arrivalTime.isEmpty == false
    }
}
