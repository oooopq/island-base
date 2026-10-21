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
    var onRetry: () -> Void = {}

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
                    tripCount: FerryPagesTimetable.scheduledTripCount(in: schedules),
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
                    tripCount: cachedSchedules.map { FerryPagesTimetable.scheduledTripCount(in: $0) } ?? 0,
                    isExpanded: $isScheduleExpanded
                ) {
                    Text(message)
                        .font(.subheadline)
                        .foregroundStyle(palette.warning)
                    FetchRetryButton(action: onRetry)

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
            destinationID: selectedDestinationID,
            language: languageStore.mode
        )

        let totalTrips = schedules.reduce(0) { $0 + $1.trips.count }
        let pagesStamp = pagesSourceStamp(in: schedules)

        if let pagesStamp, FerryPagesTimetable.isStale(sourceUpdatedAt: pagesStamp.date) {
            Text(languageStore.t(.ferryPagesStaleNotice(pagesStamp.text)))
                .font(.subheadline)
                .fontWeight(.semibold)
                .fixedSize(horizontal: false, vertical: true)
                .scheduleStatusCallout()
        }

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

        if totalTrips == 0 {
            Text(languageStore.t(.noFerryTripsToday))
                .font(.subheadline)
                .detailCardSecondaryText()
        } else if visibleSchedules.isEmpty {
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
            let suffix = IslandCatalog.ferryValidUntilSuffix(for: island.id, language: languageStore.mode) ?? ""
            Text(languageStore.t(.dataValidUntil("\(validUntilText)\(suffix)")))
                .font(.caption)
                .detailCardSecondaryText()
        }

        if let pagesStamp {
            Text(languageStore.t(.ferryPagesSourceNotice(pagesStamp.text)))
                .font(.caption)
                .detailCardSecondaryText()
                .fixedSize(horizontal: false, vertical: true)
        }

        if let cacheText = CacheAgeText.displayText(fetchedAt: fetchedAt, isFromCache: isFromCache, language: languageStore.mode) {
            Text(cacheText)
                .font(.caption)
                .detailCardSecondaryText()
        } else if pagesStamp == nil,
                  let sourceNote = IslandCatalog.ferryDataSourceNote(for: island.id, language: languageStore.mode) {
            Text(sourceNote)
                .font(.caption)
                .detailCardSecondaryText()
        }
    }

    private func pagesSourceStamp(in schedules: [FerryCompanySchedule]) -> (date: Date, text: String)? {
        guard let date = schedules.compactMap(\.sourceUpdatedAt).min() else { return nil }
        return (date, FerryPagesTimetable.displayTimestamp(date, language: languageStore.mode))
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
                        title: languageStore.t(.allDestinations),
                        isSelected: selectedDestinationID == FerryRouteHelper.allDestinationsID
                    ) {
                        selectedDestinationID = FerryRouteHelper.allDestinationsID
                    }

                    ForEach(destinations) { destination in
                        destinationChip(
                            title: IslandCatalog.displayName(for: destination.id, language: languageStore.mode),
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
                serviceKind: schedule.serviceKind,
                lineLabel: schedule.lineLabel,
                sourceUpdatedAt: schedule.sourceUpdatedAt,
                showsOperatorActions: schedule.showsOperatorActions
            )
        }
    }

    private var shipTypeLegend: some View {
        Text(languageStore.t(.highSpeedAndOvernightNote))
            .font(.caption)
            .detailCardSecondaryText()
    }

    private func hasMultipleServiceKinds(in schedules: [FerryCompanySchedule]) -> Bool {
        FerryPagesTimetable.showsHighSpeedAndOvernightLegend(schedules.map(\.serviceKind))
    }

    @ViewBuilder
    private func companyBlock(_ schedule: FerryCompanySchedule, allSchedules: [FerryCompanySchedule]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            if let serviceKind = schedule.serviceKind {
                FerryServiceKindHeaderView(
                    serviceKind: serviceKind,
                    detailText: FerryPagesTimetable.localizedLine(
                        schedule.lineLabel,
                        language: languageStore.mode
                    )
                )
            } else if let line = FerryPagesTimetable.localizedLine(
                schedule.lineLabel,
                language: languageStore.mode
            ) {
                Text(line)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }

            Text(schedule.company.displayName(for: languageStore.mode))
                .font(.subheadline)
                .fontWeight(.semibold)

            if schedule.showsOperatorActions != false {
                ScheduleOperatorActionButtonsView(
                    actions: ScheduleOperatorActionFactory.actions(for: schedule.company, language: languageStore.mode)
                )
            }

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
                    Text(IslandCatalog.localizedPlaceName(route.departure, language: languageStore.mode))
                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .detailCardSecondaryText()
                    Text(IslandCatalog.localizedPlaceName(route.arrival, language: languageStore.mode))
                }
                .font(.subheadline)
                .fontWeight(.medium)

                tripTimesAndNote(trip)
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text(IslandCatalog.localizedRouteName(trip.routeName, language: languageStore.mode))
                    .font(.subheadline)
                    .fontWeight(.medium)

                tripTimesAndNote(trip)
            }
        }
    }

    @ViewBuilder
    private func tripTimesAndNote(_ trip: FerryTrip) -> some View {
        if trip.hasScheduledTimes {
            ScheduleDepartureArrivalView(
                departureTime: trip.departureTime,
                arrivalTime: trip.arrivalTime
            )
        }

        if let note = trip.note, note.isEmpty == false {
            Text(FerryPagesTimetable.localizedSuspensionNote(note, language: languageStore.mode))
                .font(.caption)
                .foregroundStyle(palette.warning)
                .fixedSize(horizontal: false, vertical: true)
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
