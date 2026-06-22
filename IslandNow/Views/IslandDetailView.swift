//
//  IslandDetailView.swift
//  Island Now
//
//  島をタップしたあとの詳細画面（アイコンでセクション切り替え）
//

import SwiftUI

struct IslandDetailView: View {
    let island: Island

    @State private var selectedSection: IslandDetailSection = .weather
    @State private var weatherState: WeatherLoadState = .loading
    @State private var ferryState: FerryLoadState = .loading
    @State private var placesState: PlacesLoadState = .loading
    @State private var selectedPlaceCategory: PlaceCategory = .restaurant
    @State private var locationService = UserLocationService()

    private let weatherService = WeatherService()
    private let ferryService = FerryService()
    private let placesSearchService = PlacesSearchService()

    private var islandProfile: IslandProfile? {
        IslandCatalog.profile(for: island)
    }

    private var liveCameras: [LiveCamera] {
        islandProfile?.liveCameras ?? []
    }

    private var placeSearchTaskID: String {
        island.id + "-" + selectedPlaceCategory.rawValue
    }

    var body: some View {
        VStack(spacing: 0) {
            IslandDetailHeaderView(
                island: island,
                regionID: islandProfile?.regionID
            )
            .padding(.horizontal)
            .padding(.top, 6)

            IslandUserLocationMapView(
                island: island,
                islandProfile: islandProfile,
                userCoordinate: locationService.coordinate,
                authorizationStatus: locationService.authorizationStatus
            )
            .padding(.horizontal)
            .padding(.top, 6)

            IslandDetailSectionPickerView(selection: $selectedSection)
                .padding(.horizontal)
                .padding(.top, 8)

            ScrollView {
                VStack(spacing: 16) {
                    selectedSectionContent

                    Text(islandProfile?.backgroundCredit ?? "")
                        .font(.caption2)
                        .foregroundStyle(.white.opacity(0.75))
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
                .padding()
            }
        }
        .background {
            IslandBackgroundView(islandID: island.id)
        }
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .refreshable {
            await refreshAllData()
        }
        .task(id: island.id) {
            selectedSection = .weather
            selectedPlaceCategory = .restaurant
            restoreCachedStates(for: island)

            async let weatherLoad: Void = loadWeather()
            async let ferryLoad: Void = loadFerrySchedules()
            _ = await (weatherLoad, ferryLoad)
        }
        .task(id: placeSearchTaskID) {
            await loadPlaces()
        }
        .onAppear {
            locationService.start()
        }
        .onDisappear {
            locationService.stop()
        }
    }

    @ViewBuilder
    private var selectedSectionContent: some View {
        switch selectedSection {
        case .weather:
            WeatherSectionView(state: weatherState)

        case .schedule:
            FerryScheduleSectionView(island: island, state: ferryState)

            if let islandProfile, islandProfile.flightSchedules.isEmpty == false {
                FlightScheduleSectionView(
                    island: island,
                    schedules: islandProfile.flightSchedules,
                    scheduleNote: islandProfile.flightScheduleNote
                )
            }

        case .places:
            UsefulInfoSectionView(islandID: island.id)

            PlacesSectionView(
                island: island,
                selectedCategory: $selectedPlaceCategory,
                state: placesState
            )

        case .liveCamera:
            LiveCameraSectionView(islandID: island.id, cameras: liveCameras)
        }
    }

    @MainActor
    private func refreshAllData() async {
        // キャッシュがある場合は表示を維持したまま裏で更新する
        if weatherService.cachedWeather(for: island.id) == nil {
            weatherState = .loading
        }
        if ferryService.cachedSchedules(for: island.id) == nil {
            ferryState = .loading
        }
        if placesSearchService.cachedPlaces(for: island.id, category: selectedPlaceCategory) == nil {
            placesState = .loading
        }

        async let weatherLoad: Void = loadWeather()
        async let ferryLoad: Void = loadFerrySchedules()
        async let placesLoad: Void = loadPlaces()
        _ = await (weatherLoad, ferryLoad, placesLoad)
    }

    // 保存済みデータがあれば先に表示する（LTEが使えない島向け）
    @MainActor
    private func restoreCachedStates(for island: Island) {
        if let cached = weatherService.cachedWeather(for: island.id) {
            weatherState = .loaded(cached, isFromCache: true)
        } else {
            weatherState = .loading
        }

        if let cached = ferryService.cachedSchedules(for: island.id) {
            ferryState = .loaded(
                cached.schedules,
                isFromCache: true,
                validUntilText: cached.validUntilText
            )
        } else {
            ferryState = .loading
        }

        if let cached = placesSearchService.cachedPlaces(for: island.id, category: selectedPlaceCategory) {
            placesState = .loaded(cached, isFromCache: true)
        } else {
            placesState = .loading
        }
    }

    @MainActor
    private func loadWeather() async {
        if case .loading = weatherState,
           let cached = weatherService.cachedWeather(for: island.id) {
            weatherState = .loaded(cached, isFromCache: true)
        }

        do {
            let weather = try await weatherService.fetchWeather(for: island)
            weatherState = .loaded(weather, isFromCache: false)
        } catch {
            if let cached = weatherService.cachedWeather(for: island.id) {
                weatherState = .loaded(cached, isFromCache: true)
                return
            }
            weatherState = .failed(message: "天気を取得できませんでした", cachedWeather: nil)
        }
    }

    @MainActor
    private func loadFerrySchedules() async {
        if case .loading = ferryState,
           let cached = ferryService.cachedSchedules(for: island.id) {
            ferryState = .loaded(
                cached.schedules,
                isFromCache: true,
                validUntilText: cached.validUntilText
            )
        }

        do {
            let result = try await ferryService.fetchSchedules(for: island)
            ferryState = .loaded(result.schedules, isFromCache: false, validUntilText: result.validUntilText)
        } catch {
            if let cached = ferryService.cachedSchedules(for: island.id) {
                ferryState = .loaded(
                    cached.schedules,
                    isFromCache: true,
                    validUntilText: cached.validUntilText
                )
                return
            }

            let fallback = islandProfile?.sampleFerrySchedules ?? []
            ferryState = .loaded(fallback, isFromCache: true, validUntilText: nil)
        }
    }

    @MainActor
    private func loadPlaces() async {
        let category = selectedPlaceCategory

        switch placesState {
        case .loaded(let places, _) where places.first?.categoryLabel == category.rawValue:
            break
        default:
            if let cached = placesSearchService.cachedPlaces(for: island.id, category: category) {
                placesState = .loaded(cached, isFromCache: true)
            } else {
                placesState = .loading
            }
        }

        do {
            let places = try await placesSearchService.searchPlaces(for: island, category: category)
            placesState = .loaded(places, isFromCache: false)
        } catch {
            if let cached = placesSearchService.cachedPlaces(for: island.id, category: category) {
                placesState = .loaded(cached, isFromCache: true)
                return
            }
            placesState = .failed(message: "スポットを取得できませんでした", cachedPlaces: nil)
        }
    }
}

#Preview {
    NavigationStack {
        IslandDetailView(island: IslandCatalog.islands[0])
    }
}
