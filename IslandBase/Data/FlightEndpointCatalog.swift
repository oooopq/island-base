//
//  FlightEndpointCatalog.swift
//  Island Base
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
        FlightEndpoint(id: "tokyo", nameJapanese: "羽田", matchKeywords: ["羽田", "東京"]),
        FlightEndpoint(id: "chofu", nameJapanese: "調布", matchKeywords: ["調布"]),
        FlightEndpoint(id: "shizuoka", nameJapanese: "静岡", matchKeywords: ["静岡"]),
        FlightEndpoint(id: "nagasaki", nameJapanese: "長崎", matchKeywords: ["長崎"]),
        FlightEndpoint(id: "fukuoka", nameJapanese: "福岡", matchKeywords: ["福岡", "博多"]),
        FlightEndpoint(id: "hojo", nameJapanese: "北条", matchKeywords: ["北条"]),
        FlightEndpoint(id: "takahama", nameJapanese: "高浜", matchKeywords: ["高浜"]),
        FlightEndpoint(id: "mitsuhama", nameJapanese: "三津浜", matchKeywords: ["三津浜"]),
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
