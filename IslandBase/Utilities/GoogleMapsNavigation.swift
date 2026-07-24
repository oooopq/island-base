//
//  GoogleMapsNavigation.swift
//  Island Base
//
//  Google マップで場所を開く（Maps URL・API キー不要）
//

import CoreLocation
import Foundation

enum GoogleMapsNavigation {
    // 座標から Google マップの場所検索 URL を組み立てる
    static func placeURL(name: String, coordinate: CLLocationCoordinate2D) -> URL? {
        var components = URLComponents(string: "https://www.google.com/maps/search/")
        let coordinateQuery = String(
            format: "%.6f,%.6f",
            coordinate.latitude,
            coordinate.longitude
        )
        components?.queryItems = [
            URLQueryItem(name: "api", value: "1"),
            URLQueryItem(name: "query", value: coordinateQuery),
        ]
        return components?.url
    }
}
