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
    @State private var ferryState: FerryLoadState = .loading
    @State private var placesState: PlacesLoadState = .loading
    @State private var selectedPlaceCategory: PlaceCategory = .restaurant
    @State private var savedPhotoStore = IslandSavedPhotoStore()
    @State private var locationService = UserLocationService()
    @State private var isArtIntroActive = false
    @State private var detailContentVisible = true

    private let weatherService = WeatherService()
    private let ferryService = FerryService()
    private let placesSearchService = PlacesSearchService()

    private var islandProfile: IslandProfile? {
        IslandCatalog.profile(for: island)
    }

    private var usesFerryGTFS: Bool {
        islandProfile?.usesFerryGTFS == true
    }

    private var scheduleStatusSources: [ScheduleStatusSource]? {
        var sources: [ScheduleStatusSource] = []

        if usesFerryGTFS {
            sources += ScheduleStatusSourceCollector.fromFerrySchedules(currentFerrySchedules)
        }

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
        ZStack {
            detailContent
                .opacity(detailContentVisible ? 1 : 0)

            if isArtIntroActive, let artIntro = islandProfile?.artIntro {
                IslandArtIntroOverlayView(
                    assetName: islandProfile?.backgroundAssetName ?? IslandCatalog.defaultBackgroundAssetName,
                    artIntro: artIntro,
                    onZoomOutStart: {
                        withAnimation(.easeInOut(duration: artIntro.zoomOutSeconds)) {
                            detailContentVisible = true
                        }
                    },
                    onFinished: {
                        isArtIntroActive = false
                    }
                )
            }
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
            prepareArtIntro(for: island)
            selectedSection = .weather
            selectedPlaceCategory = .restaurant
            placesState = .loading
            restoreCachedStates(for: island)

            async let weatherLoad: Void = loadWeather()
            if usesFerryGTFS {
                async let ferryLoad: Void = loadFerrySchedules()
                _ = await (weatherLoad, ferryLoad)
            } else {
                await weatherLoad
            }
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

    private var detailContent: some View {
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
    }

    private func prepareArtIntro(for island: Island) {
        let shouldShowIntro = IslandCatalog.profile(for: island)?.artIntro != nil
        isArtIntroActive = shouldShowIntro
        detailContentVisible = shouldShowIntro == false
    }

    @ViewBuilder
    private var selectedSectionContent: some View {
        switch selectedSection {
        case .weather:
            WeatherSectionView(state: weatherState)

        case .schedule:
            if let scheduleStatusSources, scheduleStatusSources.isEmpty == false {
                ScheduleStatusBannerView(sources: scheduleStatusSources)
            }

            if usesFerryGTFS {
                FerryScheduleSectionView(island: island, state: ferryState)
            } else if let companies = islandProfile?.ferryLinkCompanies, companies.isEmpty == false {
                FerryLinkSectionView(companies: companies)
            }

            if let islandProfile, islandProfile.flightSchedules.isEmpty == false {
                FlightScheduleSectionView(
                    island: island,
                    schedules: islandProfile.flightSchedules,
                    scheduleNote: islandProfile.flightScheduleNote
                )
            }

            if let islandProfile {
                LiveCameraSectionView(
                    liveCameras: islandProfile.liveCameras,
                    relatedLinks: islandProfile.youtubeRelatedLinks,
                    footnote: islandProfile.liveCameraFootnote
                )
            }

        case .places:
            UsefulInfoSectionView(islandID: island.id)

            PlacesSectionView(
                island: island,
                selectedCategory: $selectedPlaceCategory,
                state: placesState
            )

        case .savedPhotos:
            IslandSavedPhotosSectionView(
                islandID: island.id,
                store: savedPhotoStore
            )
        }
    }

    @MainActor
    private func refreshAllData() async {
        // キャッシュがある場合は表示を維持したまま裏で更新する
        if weatherService.cachedWeather(for: island.id) == nil {
            weatherState = .loading
        }
        if usesFerryGTFS, ferryService.cachedSchedules(for: island.id) == nil {
            ferryState = .loading
        }
        if selectedSection == .places,
           placesSearchService.cachedPlaces(for: island.id, category: selectedPlaceCategory) == nil {
            placesState = .loading
        }

        async let weatherLoad: Void = loadWeather()
        if usesFerryGTFS {
            async let ferryLoad: Void = loadFerrySchedules()
            _ = await (weatherLoad, ferryLoad)
        } else {
            await weatherLoad
        }

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

        if usesFerryGTFS {
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
        guard usesFerryGTFS else { return }

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
