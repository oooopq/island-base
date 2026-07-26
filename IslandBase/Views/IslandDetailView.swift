//
//  IslandDetailView.swift
//  Island Base
//
//  島をタップしたあとの詳細画面（アイコンでセクション切り替え）
//

import SwiftUI

struct IslandDetailView: View {
    let island: Island

    @Environment(\.detailPalette) private var palette
    @Environment(LastSelectedIslandStore.self) private var lastSelectedIslandStore
    @Environment(AppLanguageStore.self) private var languageStore
    @State private var selectedSection: IslandDetailSection = .weather
    @State private var weatherState: WeatherLoadState = .loading
    @State private var ferryState: FerryLoadState = .loading
    @State private var placesState: PlacesLoadState = .loading
    @State private var selectedPlaceCategory: PlaceCategory = .restaurant
    @State private var savedPhotoStore = IslandSavedPhotoStore()
    @State private var locationService = UserLocationService()
    @State private var isArtIntroActive = false
    @State private var detailContentVisible = true
    @State private var blurBackgroundForReadability = false

    private let weatherService = WeatherService()
    private let ferryService = FerryService()
    private let placesSearchService = PlacesSearchService()

    private var islandProfile: IslandProfile? {
        IslandCatalog.profile(for: island)
    }

    private var usesFerryGTFS: Bool {
        islandProfile?.usesFerryGTFS == true
    }

    private var hasInAppFerryTrips: Bool {
        islandProfile?.hasInAppFerryTrips == true
    }

    /// GTFS 失敗かつキャッシュの便もないとき、公式リンクを併せて出す
    private var shouldShowFerryLinksAlongsideGTFSFailure: Bool {
        switch ferryState {
        case .failed(_, let cachedSchedules, _):
            let hasTrips = cachedSchedules?.contains { $0.trips.isEmpty == false } == true
            return hasTrips == false
        case .loading, .loaded:
            return false
        }
    }

    private var scheduleStatusSources: [ScheduleStatusSource]? {
        var sources: [ScheduleStatusSource] = []

        if hasInAppFerryTrips {
            sources += ScheduleStatusSourceCollector.fromFerrySchedules(currentFerrySchedules)
        } else if let companies = islandProfile?.ferryLinkCompanies {
            sources += ScheduleStatusSourceCollector.fromFerryCompanies(companies)
        }

        if let flightSchedules = islandProfile?.flightSchedules {
            sources += ScheduleStatusSourceCollector.fromFlightSchedules(flightSchedules)
        }

        let unique = ScheduleStatusSourceCollector.unique(sources)
        return unique.isEmpty ? nil : unique
    }

    private var currentFerrySchedules: [FerryCompanySchedule] {
        switch ferryState {
        case .loaded(let schedules, _, _, _):
            return schedules
        case .failed(_, let cachedSchedules, _):
            // 代表ダイヤは使わない。GTFS のキャッシュがあるときだけ
            return cachedSchedules ?? []
        case .loading:
            return []
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
                        withAnimation(.easeInOut(duration: 0.5)) {
                            blurBackgroundForReadability = true
                        }
                    }
                )
            }
        }
        .scrollContentBackground(.hidden)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    AppLanguageToggleButton()
                    AppThemeToggleButton()
                }
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

            if usesFerryGTFS {
                async let ferryLoad: Void = loadFerrySchedules()
                await loadWeather()
                await prefetchPlaces()
                _ = await ferryLoad
            } else {
                await loadWeather()
                await prefetchPlaces()
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
                regionDisplayName: regionDisplayName
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
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background {
            IslandBackgroundView(
                islandID: island.id,
                blurForReadability: blurBackgroundForReadability
            )
        }
    }

    private var regionDisplayName: String? {
        guard let regionID = islandProfile?.regionID else { return nil }
        return IslandRegionCatalog.displayName(for: regionID, language: languageStore.mode)
    }

    private func prepareArtIntro(for island: Island) {
        let shouldShowIntro = IslandCatalog.profile(for: island)?.artIntro != nil
        isArtIntroActive = shouldShowIntro
        detailContentVisible = shouldShowIntro == false
        blurBackgroundForReadability = shouldShowIntro == false
    }

    @ViewBuilder
    private var selectedSectionContent: some View {
        switch selectedSection {
        case .weather:
            WeatherSectionView(
                state: weatherState,
                jmaMarineForecastArea: islandProfile?.jmaMarineForecastArea ?? .setonaikai
            )

        case .schedule:
            if let jmaMarineForecastArea = islandProfile?.jmaMarineForecastArea {
                JMAMarineForecastLinkView(area: jmaMarineForecastArea)
                    .padding(16)
                    .detailSectionCard()
            }

            // 八重山以外は各社・各航空会社に運行状況があるので、先頭の欠航・遅延は出さない
            if islandProfile?.regionID == "yaeyama",
               let scheduleStatusSources,
               scheduleStatusSources.isEmpty == false {
                ScheduleStatusBannerView(sources: scheduleStatusSources)
            }

            if hasInAppFerryTrips {
                FerryScheduleSectionView(island: island, state: ferryState)

                // GTFS 取得失敗で時刻がないときは、公式リンクへ誘導する
                if shouldShowFerryLinksAlongsideGTFSFailure,
                   let companies = islandProfile?.ferryLinkCompanies,
                   companies.isEmpty == false {
                    FerryLinkSectionView(companies: companies)
                }
            } else if islandProfile?.showsFerryLinksOnly == true,
                      let companies = islandProfile?.ferryLinkCompanies {
                FerryLinkSectionView(companies: companies)
            }

            if islandProfile?.hasInAppFlightTrips == true,
               let islandProfile {
                FlightScheduleSectionView(
                    island: island,
                    schedules: islandProfile.flightSchedules,
                    scheduleNote: islandProfile.flightScheduleNote
                )
            } else if islandProfile?.showsFlightLinksOnly == true,
                      let airlines = islandProfile?.flightLinkAirlines {
                FlightLinkSectionView(airlines: airlines)
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
                state: placesState,
                userCoordinate: locationService.coordinate
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

        if usesFerryGTFS {
            async let ferryLoad: Void = loadFerrySchedules()
            await loadWeather()
            await prefetchPlaces()
            _ = await ferryLoad
        } else {
            await loadWeather()
            await prefetchPlaces()
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
                    validUntilText: cached.validUntilText,
                    fetchedAt: cached.fetchedAt
                )
            } else {
                ferryState = .loading
            }
        }

        // 飲食カテゴリのキャッシュがあればスポットタブ用に先復元する
        if let cached = placesSearchService.cachedPlaces(for: island.id, category: .restaurant) {
            placesState = .loaded(cached.places, isFromCache: true, fetchedAt: cached.fetchedAt)
        }
    }

    @MainActor
    private func loadWeather() async {
        let hasCache = weatherService.cachedWeather(for: island.id) != nil

        if case .loading = weatherState,
           let cached = weatherService.cachedWeather(for: island.id) {
            weatherState = .loaded(cached, isFromCache: true)
        }

        do {
            let weather = try await fetchWeatherWithTimeout(hasCache: hasCache)
            weatherState = .loaded(weather, isFromCache: false)
        } catch is CancellationError {
            return
        } catch NetworkTimeout.TimeoutError.timedOut {
            if let cached = weatherService.cachedWeather(for: island.id) {
                weatherState = .loaded(cached, isFromCache: true)
                return
            }
            weatherState = .failed(
                message: languageStore.t(.weatherTimeout),
                cachedWeather: nil
            )
        } catch {
            if let cached = weatherService.cachedWeather(for: island.id) {
                weatherState = .loaded(cached, isFromCache: true)
                return
            }
            weatherState = .failed(
                message: languageStore.t(.offlineWeather),
                cachedWeather: nil
            )
        }
    }

    @MainActor
    private func loadFerrySchedules() async {
        guard usesFerryGTFS else { return }

        let hasCache = ferryService.cachedSchedules(for: island.id) != nil

        if case .loading = ferryState,
           let cached = ferryService.cachedSchedules(for: island.id) {
            ferryState = .loaded(
                cached.schedules,
                isFromCache: true,
                validUntilText: cached.validUntilText,
                fetchedAt: cached.fetchedAt
            )
        }

        do {
            let result = try await fetchFerryWithTimeout(hasCache: hasCache)
            ferryState = .loaded(
                result.schedules,
                isFromCache: false,
                validUntilText: result.validUntilText,
                fetchedAt: result.fetchedAt
            )
        } catch is CancellationError {
            return
        } catch {
            if let cached = ferryService.cachedSchedules(for: island.id) {
                ferryState = .loaded(
                    cached.schedules,
                    isFromCache: true,
                    validUntilText: cached.validUntilText,
                    fetchedAt: cached.fetchedAt
                )
                return
            }

            // GTFS 取得失敗・キャッシュもない場合は代表ダイヤを出さない
            ferryState = .failed(
                message: languageStore.t(.offlineFerry),
                cachedSchedules: nil,
                fetchedAt: nil
            )
        }
    }

    @MainActor
    private func loadPlaces() async {
        let category = selectedPlaceCategory
        let cachedEntry = placesSearchService.cachedPlaces(for: island.id, category: category)
        let hasCache = cachedEntry != nil

        switch placesState {
        case .loaded(let places, _, _) where places.first?.categoryLabel == category.rawValue:
            break
        default:
            if let cachedEntry {
                placesState = .loaded(cachedEntry.places, isFromCache: true, fetchedAt: cachedEntry.fetchedAt)
            } else {
                placesState = .loading
            }
        }

        do {
            let entry = try await fetchPlacesWithTimeout(category: category, hasCache: hasCache)
            placesState = .loaded(entry.places, isFromCache: false, fetchedAt: entry.fetchedAt)
        } catch is CancellationError {
            return
        } catch {
            if let cachedEntry {
                placesState = .loaded(cachedEntry.places, isFromCache: true, fetchedAt: cachedEntry.fetchedAt)
                return
            }
            placesState = .failed(
                message: languageStore.t(.offlinePlaces),
                cachedPlaces: nil,
                fetchedAt: nil
            )
        }
    }

    /// 島を開いた時点で主要スポットを裏で保存する（圏外対策）
    @MainActor
    private func prefetchPlaces() async {
        for category in PlaceCategory.allCases {
            do {
                // 圏外で長く待たないよう短めのタイムアウト
                _ = try await NetworkTimeout.withTimeout {
                    try await placesSearchService.searchPlaces(for: island, category: category)
                }
            } catch is CancellationError {
                return
            } catch {
                continue
            }
        }

        // いまスポットタブを開いているカテゴリなら表示を最新に合わせる
        if selectedSection == .places,
           let cached = placesSearchService.cachedPlaces(for: island.id, category: selectedPlaceCategory) {
            placesState = .loaded(cached.places, isFromCache: false, fetchedAt: cached.fetchedAt)
        }
    }

    private func fetchWeatherWithTimeout(hasCache: Bool) async throws -> WeatherInfo {
        if hasCache {
            return try await weatherService.fetchWeather(for: island)
        }

        let fetch = {
            try await NetworkTimeout.withTimeout(seconds: NetworkTimeout.weatherSeconds) {
                try await weatherService.fetchWeather(for: island)
            }
        }

        do {
            return try await fetch()
        } catch NetworkTimeout.TimeoutError.timedOut {
            // Open-Meteo が遅いときがあるため、1回だけ再試行する
            return try await fetch()
        }
    }

    private func fetchFerryWithTimeout(hasCache: Bool) async throws -> FerryFetchResult {
        if hasCache {
            return try await ferryService.fetchSchedules(for: island)
        }
        return try await NetworkTimeout.withTimeout {
            try await ferryService.fetchSchedules(for: island)
        }
    }

    private func fetchPlacesWithTimeout(
        category: PlaceCategory,
        hasCache: Bool
    ) async throws -> PlacesCacheEntry {
        if hasCache {
            return try await placesSearchService.searchPlaces(for: island, category: category)
        }
        return try await NetworkTimeout.withTimeout {
            try await placesSearchService.searchPlaces(for: island, category: category)
        }
    }
}

#Preview {
    NavigationStack {
        IslandDetailView(island: IslandCatalog.islands[0])
    }
    .environment(LastSelectedIslandStore())
    .environment(AppLanguageStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
