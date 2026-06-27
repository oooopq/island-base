//
//  PlaceInfo.swift
//  Island Now
//
//  MapKit 検索で見つかった店舗・施設
//

import CoreLocation
import Foundation
import MapKit

struct PlaceInfo: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let categoryLabel: String
    let address: String?
    let latitude: Double
    let longitude: Double
    let phoneNumber: String?
    let websiteURLString: String?
    let mapsURLString: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var websiteURL: URL? {
        AppURL.from(string: websiteURLString)
    }

    // Apple マップで車での案内を開く
    func openDrivingDirections() {
        AppleMapsNavigation.openDrivingDirections(name: name, coordinate: coordinate)
    }

    // MKMapItem からアプリ用のモデルに変換する
    static func from(mapItem: MKMapItem, categoryLabel: String) -> PlaceInfo? {
        guard let name = mapItem.name, name.isEmpty == false else {
            return nil
        }

        let coordinate = mapItem.placemark.coordinate
        let address = mapItem.placemark.title
        let websiteURL = extractWebsiteURL(from: mapItem.url)

        return PlaceInfo(
            id: "\(name)-\(coordinate.latitude)-\(coordinate.longitude)",
            name: name,
            categoryLabel: categoryLabel,
            address: address,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            phoneNumber: mapItem.phoneNumber,
            websiteURLString: websiteURL?.absoluteString,
            mapsURLString: nil
        )
    }

    private static func extractWebsiteURL(from url: URL?) -> URL? {
        guard let url else { return nil }
        guard let scheme = url.scheme?.lowercased(), scheme == "http" || scheme == "https" else {
            return nil
        }
        if url.host?.contains("maps.apple.com") == true {
            return nil
        }
        return url
    }

    // 島の中心からの距離（メートル）を計算する
    func distanceMeters(from island: Island) -> CLLocationDistance {
        let placeLocation = CLLocation(latitude: latitude, longitude: longitude)
        let islandLocation = CLLocation(latitude: island.latitude, longitude: island.longitude)
        return placeLocation.distance(from: islandLocation)
    }
}
