//
//  FlightEndpointCatalog.swift
//  Island Now
//
//  アプリに登録されていない空港・港（那覇・新潟・東京など）の行き先判別
//

import Foundation

struct FlightEndpoint: Identifiable {
    let id: String
    let nameJapanese: String
    let matchKeywords: [String]
}

enum FlightEndpointCatalog {
    static let all: [FlightEndpoint] = [
        FlightEndpoint(id: "naha", nameJapanese: "那覇", matchKeywords: ["那覇"]),
        FlightEndpoint(id: "niigata", nameJapanese: "新潟", matchKeywords: ["新潟"]),
        FlightEndpoint(id: "tokyo", nameJapanese: "東京", matchKeywords: ["東京", "羽田", "調布"]),
        FlightEndpoint(id: "shizuoka", nameJapanese: "静岡", matchKeywords: ["静岡"]),
    ]

    static func endpointID(matchingPlaceName placeName: String) -> String? {
        all.first { endpoint in
            endpoint.matchKeywords.contains { placeName.contains($0) }
        }?.id
    }

    static func displayName(for endpointID: String) -> String? {
        all.first { $0.id == endpointID }?.nameJapanese
    }
}
