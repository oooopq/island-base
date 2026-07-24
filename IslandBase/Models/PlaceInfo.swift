//
//  PlaceInfo.swift
//  Island Base
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

    var googleMapsURL: URL? {
        if let mapsURLString, let url = AppURL.from(string: mapsURLString) {
            return url
        }
        return GoogleMapsNavigation.placeURL(name: name, coordinate: coordinate)
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

        let googleMapsURL = GoogleMapsNavigation.placeURL(name: name, coordinate: coordinate)

        return PlaceInfo(
            id: "\(name)-\(coordinate.latitude)-\(coordinate.longitude)",
            name: name,
            categoryLabel: categoryLabel,
            address: address,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            phoneNumber: mapItem.phoneNumber,
            websiteURLString: websiteURL?.absoluteString,
            mapsURLString: googleMapsURL?.absoluteString
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
        distanceMeters(from: island.coordinate)
    }

    // 任意の地点からの距離（メートル）
    func distanceMeters(from coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        let placeLocation = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return placeLocation.distance(from: otherLocation)
    }
}
