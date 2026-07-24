//
//  PlacesSectionView.swift
//  Island Base
//
//  詳細画面のスポットセクション（飲食店・宿・商店）
//  島外は港から近い順、島内は現在地から近い順
//

import CoreLocation
import SwiftUI

struct PlacesSectionView: View {
    let island: Island
    @Binding var selectedCategory: PlaceCategory
    let state: PlacesLoadState
    /// 詳細画面で取得した現在地（無いときは港基準のまま）
    var userCoordinate: CLLocationCoordinate2D? = nil

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore

    private var isOnIsland: Bool {
        guard let userCoordinate else { return false }
        let status = IslandUserLocationViewModel(
            island: island,
            islandProfile: IslandCatalog.profile(for: island)
        ).status(for: userCoordinate)
        return status.isOnIsland
    }

    private var showsDistanceInfo: Bool {
        selectedCategory == .restaurant || selectedCategory == .lodging
    }

    private var distanceCaption: String? {
        guard showsDistanceInfo else { return nil }

        if isOnIsland {
            return languageStore.t(.userDistanceCaption)
        }

        let ports = IslandCatalog.ports(for: island.id)
        guard ports.isEmpty == false else { return nil }
        if ports.count <= 1, let port = ports.first {
            return languageStore.t(.portDistanceSingle(port.name))
        }
        let names = ports.map(\.name).joined(separator: "・")
        return languageStore.t(.portDistanceMultiple(names))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(languageStore.t(.spots))
                .font(.headline)

            Picker(languageStore.t(.category), selection: $selectedCategory) {
                ForEach(PlaceCategory.allCases) { category in
                    Text(category.title(for: languageStore.mode)).tag(category)
                }
            }
            .pickerStyle(.segmented)

            if let distanceCaption {
                Text(distanceCaption)
                    .font(.caption)
                    .detailCardSecondaryText()
            }

            switch state {
            case .loading:
                ProgressView(languageStore.t(.searchingPlaces))
                    .tint(palette.accent)
                    .detailCardSecondaryText()

            case .loaded(let places, let isFromCache, let fetchedAt):
                placesListContent(places)

                if let cacheText = CacheAgeText.displayText(fetchedAt: fetchedAt, isFromCache: isFromCache, language: languageStore.mode) {
                    Text(cacheText)
                        .font(.caption)
                        .detailCardSecondaryText()
                } else {
                    Text(languageStore.t(.appleMapsData))
                        .font(.caption)
                        .detailCardSecondaryText()
                }

            case .failed(let message, let cachedPlaces, let fetchedAt):
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(palette.warning)

                if let cachedPlaces, cachedPlaces.isEmpty == false {
                    placesListContent(cachedPlaces)
                    if let cacheText = CacheAgeText.displayText(fetchedAt: fetchedAt, isFromCache: true, language: languageStore.mode) {
                        Text(cacheText)
                            .font(.caption)
                            .detailCardSecondaryText()
                    }
                }
            }
        }
        .detailSectionCard()
    }

    @ViewBuilder
    private func placesListContent(_ places: [PlaceInfo]) -> some View {
        if places.isEmpty {
            Text(languageStore.t(.noPlacesInCategory))
                .font(.subheadline)
                .detailCardSecondaryText()
        } else {
            let ordered = orderedPlaces(places)
            let visiblePlaces = Array(ordered.prefix(IslandCatalog.placeDisplayLimit))
            ForEach(Array(visiblePlaces.enumerated()), id: \.element.id) { index, place in
                if index > 0 {
                    Divider()
                }
                placeRow(place)
            }

            if ordered.count > IslandCatalog.placeDisplayLimit {
                Text(languageStore.t(.morePlaces(ordered.count - IslandCatalog.placeDisplayLimit)))
                    .font(.caption)
                    .detailCardSecondaryText()
            }
        }
    }

    /// 島内かつ現在地があるときは現在地から近い順。それ以外は取得時の港順のまま
    private func orderedPlaces(_ places: [PlaceInfo]) -> [PlaceInfo] {
        guard isOnIsland, let userCoordinate else { return places }
        return places.sorted { lhs, rhs in
            lhs.distanceMeters(from: userCoordinate) < rhs.distanceMeters(from: userCoordinate)
        }
    }

    private func placeRow(_ place: PlaceInfo) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName(for: place.categoryLabel))
                .frame(width: 24)
                .foregroundStyle(palette.iconAccent)

            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.subheadline)
                    .fontWeight(.medium)

                if showsDistanceInfo, let accessText = distanceAccessText(for: place) {
                    Text(accessText)
                        .font(.caption)
                        .detailCardSecondaryText()
                }

                if let address = place.address, address != place.name {
                    Text(address)
                        .font(.caption)
                        .detailCardSecondaryText()
                }

                if let phoneNumber = place.phoneNumber, phoneNumber.isEmpty == false {
                    Text(phoneNumber)
                        .font(.caption)
                        .detailCardSecondaryText()
                }
            }

            Spacer(minLength: 4)

            DetailRowLinkButtonsView(
                websiteURL: place.websiteURL,
                googleMapsURL: place.googleMapsURL,
                onNavigate: { place.openDrivingDirections() }
            )
        }
    }

    private func distanceAccessText(for place: PlaceInfo) -> String? {
                if isOnIsland, let userCoordinate {
            let meters = place.distanceMeters(from: userCoordinate)
            return languageStore.t(
                .placeUserDistance(
                    IslandCatalog.formattedDistance(meters),
                    IslandCatalog.formattedWalkingTime(meters, language: languageStore.mode)
                )
            )
        }
        return IslandCatalog.formattedPortAccess(from: place, islandID: island.id)
    }

    private func iconName(for categoryLabel: String) -> String {
        switch categoryLabel {
        case PlaceCategory.restaurant.rawValue:
            return "fork.knife"
        case PlaceCategory.lodging.rawValue:
            return "bed.double.fill"
        case PlaceCategory.shop.rawValue:
            return "bag.fill"
        default:
            return "mappin.and.ellipse"
        }
    }
}

#Preview {
    PlacesSectionView(
        island: IslandCatalog.islands[0],
        selectedCategory: .constant(.restaurant),
        state: .loaded(
            [
                PlaceInfo(
                    id: "1",
                    name: "八重山そば 示例",
                    categoryLabel: "飲食店",
                    address: "沖縄県石垣市",
                    latitude: 24.34,
                    longitude: 124.15,
                    phoneNumber: "0980-00-0000",
                    websiteURLString: "https://example.com/",
                    mapsURLString: nil
                ),
            ],
            isFromCache: false,
            fetchedAt: Date()
        ),
        userCoordinate: nil
    )
    .padding()
    .environment(AppLanguageStore())
}
