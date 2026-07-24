//
//  AppleMapsNavigation.swift
//  Island Base
//
//  Apple マップで車での案内を開く（MKMapItem API）
//

import CoreLocation
import MapKit

enum AppleMapsNavigation {
    private static let drivingLaunchOptions: [String: Any] = [
        MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,
    ]

    /// 島周辺に検索範囲を絞るときのおおよその span（度）
    private static let islandSearchSpan = MKCoordinateSpan(latitudeDelta: 0.35, longitudeDelta: 0.35)

    // 座標が分かっている場所を Apple マップで案内する
    static func openDrivingDirections(name: String, coordinate: CLLocationCoordinate2D) {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: coordinate))
        mapItem.name = name
        mapItem.openInMaps(launchOptions: drivingLaunchOptions)
    }

    // 施設名＋住所で検索し、島座標付近に絞って案内する（お役立ち情報用）
    static func openDrivingDirections(
        name: String,
        address: String,
        searchRegionCenter: CLLocationCoordinate2D?
    ) async {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        let query: String
        if trimmedAddress.isEmpty {
            query = trimmedName
        } else if trimmedName.isEmpty {
            query = trimmedAddress
        } else {
            query = "\(trimmedName) \(trimmedAddress)"
        }

        guard query.isEmpty == false else { return }

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        if let searchRegionCenter {
            request.region = MKCoordinateRegion(
                center: searchRegionCenter,
                span: islandSearchSpan
            )
        }

        guard let response = try? await MKLocalSearch(request: request).start(),
              let mapItem = response.mapItems.first else {
            return
        }

        mapItem.name = trimmedName.isEmpty ? nil : trimmedName
        await MainActor.run {
            mapItem.openInMaps(launchOptions: drivingLaunchOptions)
        }
    }
}
