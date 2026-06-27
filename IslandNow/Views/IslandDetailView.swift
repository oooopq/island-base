//
//  IslandDetailView.swift
//  Island Now
//
//  島をタップしたあとの詳細画面（アイコンでセクション切り替え）
//

import SwiftUI

struct IslandDetailView: View {
    let island: Island

    @Environment(\.detailPalette) private var palette
    @Environment(LastSelectedIslandStore.self) private var lastSelectedIslandStore
    @State private var selectedSection: IslandDetailSection = .weather
    @State private var weatherState: WeatherLoadState = .loading
    @State private var heatStrokeState: HeatStrokeRiskLoadState = .unavailable
    @State private var ferryState: FerryLoadState = .loading
    @State private var placesState: PlacesLoadState = .loading
    @State private var selectedPlaceCategory: PlaceCategory = .restaurant
    @State private var locationService = UserLocationService()

    private let weatherService = WeatherService()
    private let wbgtService = WBGTService()
    private let ferryService = FerryService()
    private let placesSearchService = PlacesSearchService()

    private var islandProfile: IslandProfile? {
        IslandCatalog.profile(for: island)
    }

    private var scheduleStatusSources: [ScheduleStatusSource]? {
        var sources: [ScheduleStatusSource] = []

        let ferrySchedules = currentFerrySchedules
        sources += ScheduleStatusSourceCollector.fromFerrySchedules(ferrySchedules)

        if let flightSchedules = islandProfile?.flightSchedules {
            sources += ScheduleStatusSourceCollector.fromFlightSchedules(flightSchedules)
        }

        let unique = ScheduleStatusSourceCollector.unique(sources)
        return unique.isEmpty ? nil : unique
    }

    private var currentFerrySchedules: [FerryCompanySchedule] {
        switch ferryState {
        case .loaded(let schedules, _, _):
            return schedules
        case .failed(_, let cachedSchedules):
            return cachedSchedules ?? islandProfile?.sampleFerrySchedules ?? []
        case .loading:
            return islandProfile?.sampleFerrySchedules ?? []
        }
    }

    // スポットタブ表示時だけ店舗検索を走らせる（初回表示を軽くする）
    private var placeSearchTaskID: String {
        island.id + "-" + selectedSection.rawValue + "-" + selectedPlaceCategory.rawValue
    }

    var body: some View {
        VStack(spacing: 0) {
            IslandDetailHeaderView(
                island: island,
                regionDisplayName: islandProfile?.regionDisplayName
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
                        .foregroundStyle(palette.captionOnPhoto)
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                AppThemeToggleButton()
            }
        }
        .refreshable {
            await refreshAllData()
        }
        .task(id: island.id) {
            selectedSection = .weather
            selectedPlaceCategory = .restaurant
            placesState = .loading
            restoreCachedStates(for: island)

            async let weatherLoad: Void = loadWeather()
            async let heatStrokeLoad: Void = loadHeatStrokeRisk()
            async let ferryLoad: Void = loadFerrySchedules()
            _ = await (weatherLoad, heatStrokeLoad, ferryLoad)
        }
        .task(id: placeSearchTaskID) {
            guard selectedSection == .places else { return }
            await loadPlaces()
        }
        .onAppear {
            lastSelectedIslandStore.record(island)
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
            WeatherSectionView(state: weatherState, heatStrokeState: heatStrokeState)

        case .schedule:
            if let scheduleStatusSources, scheduleStatusSources.isEmpty == false {
                ScheduleStatusBannerView(sources: scheduleStatusSources)
            }

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
            LiveCameraSectionView(
                liveCameras: islandProfile?.liveCameras ?? [],
                youtubeRelatedLinks: islandProfile?.youtubeRelatedLinks ?? [],
                footnote: islandProfile?.liveCameraFootnote
            )
        }
    }

    @MainActor
    private func refreshAllData() async {
        // キャッシュがある場合は表示を維持したまま裏で更新する
        if weatherService.cachedWeather(for: island.id) == nil {
            weatherState = .loading
        }
        if islandProfile?.wbgtStationNo != nil,
           WBGTService.isInSeason,
           wbgtService.cachedRisk(for: island.id) == nil {
            heatStrokeState = .loading
        }
        if ferryService.cachedSchedules(for: island.id) == nil {
            ferryState = .loading
        }
        if selectedSection == .places,
           placesSearchService.cachedPlaces(for: island.id, category: selectedPlaceCategory) == nil {
            placesState = .loading
        }

        async let weatherLoad: Void = loadWeather()
        async let heatStrokeLoad: Void = loadHeatStrokeRisk()
        async let ferryLoad: Void = loadFerrySchedules()
        _ = await (weatherLoad, heatStrokeLoad, ferryLoad)

        if selectedSection == .places {
            await loadPlaces()
        }
    }

    // 保存済みデータがあれば先に表示する（LTEが使えない島向け）
    @MainActor
    private func restoreCachedStates(for island: Island) {
        if let cached = weatherService.cachedWeather(for: island.id) {
            weatherState = .loaded(cached, isFromCache: true)
        } else {
            weatherState = .loading
        }

        restoreHeatStrokeState(for: island)

        if let cached = ferryService.cachedSchedules(for: island.id) {
            ferryState = .loaded(
                cached.schedules,
                isFromCache: true,
                validUntilText: cached.validUntilText
            )
        } else {
            ferryState = .loading
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
    private func restoreHeatStrokeState(for island: Island) {
        guard islandProfile?.wbgtStationNo != nil, WBGTService.isInSeason else {
            heatStrokeState = .unavailable
            return
        }

        if let cached = wbgtService.cachedRisk(for: island.id) {
            heatStrokeState = .loaded(cached, isFromCache: true)
        } else {
            heatStrokeState = .loading
        }
    }

    @MainActor
    private func loadHeatStrokeRisk() async {
        guard let stationNo = islandProfile?.wbgtStationNo, WBGTService.isInSeason else {
            heatStrokeState = .unavailable
            return
        }

        if case .loading = heatStrokeState,
           let cached = wbgtService.cachedRisk(for: island.id) {
            heatStrokeState = .loaded(cached, isFromCache: true)
        }

        do {
            if let risk = try await wbgtService.fetchRisk(stationNo: stationNo, islandID: island.id) {
                heatStrokeState = .loaded(risk, isFromCache: false)
            } else {
                heatStrokeState = .unavailable
            }
        } catch {
            if let cached = wbgtService.cachedRisk(for: island.id) {
                heatStrokeState = .loaded(cached, isFromCache: true)
            } else {
                heatStrokeState = .failed
            }
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

            // GTFS 取得失敗・キャッシュもない場合はサンプルダイヤを .failed として表示
            let fallback = islandProfile?.sampleFerrySchedules ?? []
            ferryState = .failed(
                message: "ダイヤを取得できませんでした。代表ダイヤ（参考）を表示しています。",
                cachedSchedules: fallback.isEmpty ? nil : fallback
            )
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
    .environment(LastSelectedIslandStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
