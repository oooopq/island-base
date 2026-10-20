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
    var nameEnglish: String? = nil
    let matchKeywords: [String]

    func displayName(for language: AppLanguageMode) -> String {
        if language == .english, let nameEnglish, nameEnglish.isEmpty == false {
            return nameEnglish
        }
        return nameJapanese
    }
}

enum FlightEndpointCatalog {
    static let all: [FlightEndpoint] = [
        FlightEndpoint(id: "naha", nameJapanese: "那覇", nameEnglish: "Naha", matchKeywords: ["那覇"]),
        FlightEndpoint(id: "niigata", nameJapanese: "新潟", nameEnglish: "Niigata", matchKeywords: ["新潟"]),
        FlightEndpoint(id: "tokyo", nameJapanese: "羽田", nameEnglish: "Haneda", matchKeywords: ["羽田", "東京"]),
        FlightEndpoint(id: "chofu", nameJapanese: "調布", nameEnglish: "Chofu", matchKeywords: ["調布"]),
        FlightEndpoint(id: "shizuoka", nameJapanese: "静岡", nameEnglish: "Shizuoka", matchKeywords: ["静岡"]),
        FlightEndpoint(id: "nagasaki", nameJapanese: "長崎", nameEnglish: "Nagasaki", matchKeywords: ["長崎"]),
        FlightEndpoint(id: "fukuoka", nameJapanese: "福岡", nameEnglish: "Fukuoka", matchKeywords: ["福岡", "博多"]),
        FlightEndpoint(id: "hojo", nameJapanese: "北条", nameEnglish: "Hojo", matchKeywords: ["北条"]),
        FlightEndpoint(id: "takahama", nameJapanese: "高浜", nameEnglish: "Takahama", matchKeywords: ["高浜"]),
        FlightEndpoint(id: "mitsuhama", nameJapanese: "三津浜", nameEnglish: "Mitsuhama", matchKeywords: ["三津浜"]),
    ]

    static func endpointID(matchingPlaceName placeName: String) -> String? {
        all.first { endpoint in
            endpoint.matchKeywords.contains { placeName.contains($0) }
        }?.id
    }

    static func displayName(for endpointID: String, language: AppLanguageMode = .japanese) -> String? {
        all.first { $0.id == endpointID }?.displayName(for: language)
    }
}
