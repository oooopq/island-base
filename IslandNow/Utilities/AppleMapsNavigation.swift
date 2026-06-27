//
//  AppleMapsNavigation.swift
//  Island Now
//
//  Apple マップで車での案内を開く（MKMapItem API）
//

import CoreLocation
import MapKit

enum AppleMapsNavigation {
    private static let drivingLaunchOptions: [String: Any] = [
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
    ]

    // 座標が分かっている場所を Apple マップで案内する
    static func openDrivingDirections(name: String, coordinate: CLLocationCoordinate2D) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: drivingLaunchOptions)
    }

    // 住所文字列から場所を検索して案内する（お役立ち情報用）
    static func openDrivingDirections(name: String, address: String) async {
        let query = address.isEmpty ? name : address
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query

        guard let response = try? await MKLocalSearch(request: request).start(),
              let mapItem = response.mapItems.first else {
            return
        }

        mapItem.name = name
        await MainActor.run {
            mapItem.openInMaps(launchOptions: drivingLaunchOptions)
        }
    }
}
