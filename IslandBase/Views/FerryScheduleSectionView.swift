//
//  FerryScheduleSectionView.swift
//  Island Base
//
//  詳細画面のフェリーダイヤセクション
//

import SwiftUI

struct FerryScheduleSectionView: View {
    let island: Island
    let state: FerryLoadState

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
    @State private var selectedDestinationID = FerryRouteHelper.allDestinationsID
    @State private var isScheduleExpanded = true

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            switch state {
            case .loading:
                ScheduleTransportCardView(
                    kind: .ferry,
                    tripCount: 0,
                    isExpanded: $isScheduleExpanded
                ) {
                    ProgressView(languageStore.t(.loadingSchedule))
                        .tint(ScheduleTransportKind.ferry.accentColor)
                        .detailCardSecondaryText()
                }

            case .loaded(let schedules, let isFromCache, let validUntilText, let fetchedAt):
                ScheduleTransportCardView(
                    kind: .ferry,
                    tripCount: schedules.reduce(0) { $0 + $1.trips.count },
                    isExpanded: $isScheduleExpanded
                ) {
                    scheduleContent(
                        schedules: schedules,
                        isFromCache: isFromCache,
                        validUntilText: validUntilText,
                        fetchedAt: fetchedAt
                    )
                }

            case .failed(let message, let cachedSchedules, let fetchedAt):
                ScheduleTransportCardView(
                    kind: .ferry,
                    tripCount: cachedSchedules?.reduce(0) { $0 + $1.trips.count } ?? 0,
                    isExpanded: $isScheduleExpanded
                ) {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(palette.warning)

                    if let cachedSchedules {
                        scheduleContent(
                            schedules: cachedSchedules,
                            isFromCache: true,
                            validUntilText: nil,
                            fetchedAt: fetchedAt
                        )
                    }
                }
            }
        }
        .detailSectionCard()
        .onChange(of: island.id) { _, _ in
            resetSchedulePresentation()
        }
        .onChange(of: stateKey) { _, _ in
            resetSchedulePresentation()
        }
    }

    @ViewBuilder
    private func scheduleContent(
        schedules: [FerryCompanySchedule],
        isFromCache: Bool,
        validUntilText: String?,
        fetchedAt: Date? = nil
    ) -> some View {
        let destinations = FerryRouteHelper.destinations(in: schedules, currentIslandID: island.id)
        let visibleSchedules = filteredSchedules(schedules)
        let nextDepartures = NextDepartureHelper.nextFerryDepartures(
            from: schedules,
            islandID: island.id,
            destinationID: selectedDestinationID
        )

        if destinations.isEmpty == false {
            destinationPicker(destinations: destinations)
        }

        if nextDepartures.isEmpty == false {
            NextDepartureBannerView(
                title: languageStore.t(.nextFerry),
                departures: nextDepartures,
                showsTomorrowNote: NextDepartureHelper.isTodayFinished(nextDepartures),
                accentColor: ScheduleTransportKind.ferry.accentColor
            )
        }

        if visibleSchedules.isEmpty {
            Text(languageStore.t(.noTripsForDestination))
                .font(.subheadline)
                .detailCardSecondaryText()
        } else {
            if hasMultipleServiceKinds(in: visibleSchedules) {
                shipTypeLegend
            }

            ForEach(visibleSchedules) { schedule in
                companyBlock(schedule, allSchedules: visibleSchedules)
            }
        }

        if let validUntilText {
            let suffix = IslandCatalog.ferryValidUntilSuffix(for: island.id) ?? ""
            Text(languageStore.t(.dataValidUntil("\(validUntilText)\(suffix)")))
                .font(.caption)
                .detailCardSecondaryText()
        }

        if let cacheText = CacheAgeText.displayText(fetchedAt: fetchedAt, isFromCache: isFromCache, language: languageStore.mode) {
            Text(cacheText)
                .font(.caption)
                .detailCardSecondaryText()
        } else if let sourceNote = IslandCatalog.ferryDataSourceNote(for: island.id) {
            Text(sourceNote)
                .font(.caption)
                .detailCardSecondaryText()
        }
    }

    @ViewBuilder
    private func destinationPicker(destinations: [FerryDestination]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageStore.t(.destinations))
                .font(.subheadline)
                .detailCardSecondaryText()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    destinationChip(
                        title: "すべて",
                        isSelected: selectedDestinationID == FerryRouteHelper.allDestinationsID
                    ) {
                        selectedDestinationID = FerryRouteHelper.allDestinationsID
                    }

                    ForEach(destinations) { destination in
                        destinationChip(
                            title: destination.nameJapanese,
                            isSelected: selectedDestinationID == destination.id
                        ) {
                            selectedDestinationID = destination.id
                        }
                    }
                }
            }
        }
    }

    private func destinationChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(palette.chipBackground(isSelected: isSelected))
                .foregroundStyle(palette.chipForeground(isSelected: isSelected))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func filteredSchedules(_ schedules: [FerryCompanySchedule]) -> [FerryCompanySchedule] {
        schedules.compactMap { schedule in
            let trips = FerryRouteHelper.filteredTrips(
                schedule.trips,
                destinationID: selectedDestinationID,
                currentIslandID: island.id
            )
            guard trips.isEmpty == false else { return nil }
            return FerryCompanySchedule(
                id: schedule.id,
                company: schedule.company,
                trips: trips,
                serviceKind: schedule.serviceKind
            )
        }
    }

    private var shipTypeLegend: some View {
        Text(languageStore.t(.highSpeedAndOvernightNote))
            .font(.caption)
            .detailCardSecondaryText()
    }

    private func hasMultipleServiceKinds(in schedules: [FerryCompanySchedule]) -> Bool {
        let kinds = Set(schedules.compactMap(\.serviceKind))
        return kinds.count > 1
    }

    @ViewBuilder
    private func companyBlock(_ schedule: FerryCompanySchedule, allSchedules: [FerryCompanySchedule]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let serviceKind = schedule.serviceKind {
                FerryServiceKindHeaderView(serviceKind: serviceKind)
            }

            Text(schedule.company.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            ScheduleOperatorActionButtonsView(
                actions: ScheduleOperatorActionFactory.actions(for: schedule.company, language: languageStore.mode)
            )

            ForEach(Array(schedule.trips.enumerated()), id: \.element.id) { index, trip in
                if index > 0 {
                    Divider()
                }
                tripRow(trip)
            }
        }

        if schedule.id != allSchedules.last?.id {
            Divider()
        }
    }

    @ViewBuilder
    private func tripRow(_ trip: FerryTrip) -> some View {
        if let route = FerryRouteHelper.parseRoute(trip.routeName) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Text(route.departure)
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .detailCardSecondaryText()
                    Text(route.arrival)
                }
                .font(.subheadline)
                .fontWeight(.medium)

                ScheduleDepartureArrivalView(
                    departureTime: trip.departureTime,
                    arrivalTime: trip.arrivalTime
                )
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(trip.routeName)
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScheduleDepartureArrivalView(
                    departureTime: trip.departureTime,
                    arrivalTime: trip.arrivalTime
                )
            }
        }
    }

    private func resetSchedulePresentation() {
        selectedDestinationID = FerryRouteHelper.allDestinationsID
        isScheduleExpanded = true
    }

    private var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case .loaded(let schedules, let isFromCache, _, _):
            let tripCount = schedules.reduce(0) { $0 + $1.trips.count }
            return "loaded-\(tripCount)-\(isFromCache)"
        case .failed(let message, let cached, _):
            let tripCount = cached?.reduce(0) { $0 + $1.trips.count } ?? 0
            return "failed-\(message)-\(tripCount)"
        }
    }
}

#Preview {
    FerryScheduleSectionView(
        island: IslandCatalog.islands[0],
        state: .loaded(
            IslandCatalog.profile(for: "ishigaki")?.sampleFerrySchedules ?? [],
            isFromCache: false,
            validUntilText: "2026/06/19",
            fetchedAt: Date()
        )
    )
    .padding()
}
