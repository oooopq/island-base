//
//  PortAccessInfo.swift
//  Island Now
//
//  港から現在地・スポットまでの距離表示
//

import CoreLocation
import Foundation

struct PortAccessInfo {
    let port: IslandPort
    let directionLabel: String
    let distanceMeters: CLLocationDistance

    var formattedLine: String {
        formattedLine(includeWalkingTime: true)
    }

    func formattedLine(includeWalkingTime: Bool) -> String {
        let distanceText = IslandCatalog.formattedDistance(distanceMeters)
        if includeWalkingTime {
            return "\(port.name)（\(directionLabel)）から \(distanceText)（\(IslandCatalog.formattedWalkingTime(distanceMeters))）"
        }
        return "\(port.name)（\(directionLabel)）から \(distanceText)"
    }
}

enum PortDirectionHelper {
    /// 島の中心から見た港の方角（8方位）
    static func directionLabel(
        from islandCenter: CLLocationCoordinate2D,
        to target: CLLocationCoordinate2D
    ) -> String {
        let lat1 = islandCenter.latitude * .pi / 180
        let lat2 = target.latitude * .pi / 180
        let deltaLongitude = (target.longitude - islandCenter.longitude) * .pi / 180

        let y = sin(deltaLongitude) * cos(lat2)
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(deltaLongitude)
        var bearing = atan2(y, x) * 180 / .pi
        if bearing < 0 {
            bearing += 360
        }

        let directions = ["北", "北東", "東", "南東", "南", "南西", "西", "北西"]
        let index = Int((bearing + 22.5) / 45.0) % 8
        return directions[index]
    }
}
