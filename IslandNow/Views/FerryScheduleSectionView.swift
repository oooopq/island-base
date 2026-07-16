//
//  FerryScheduleSectionView.swift
//  Island Now
//
//  詳細画面のフェリーダイヤセクション
//

import SwiftUI

struct FerryScheduleSectionView: View {
    let island: Island
    let state: FerryLoadState

    @Environment(\.detailPalette) private var palette
    @State private var selectedDestinationID = FerryRouteHelper.allDestinationsID
    @State private var isFullScheduleExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("船便")
                    .font(.headline)
                Text("フェリー・高速船")
                    .font(.caption)
                    .detailCardSecondaryText()
            }

            switch state {
            case .loading:
                ProgressView("ダイヤを取得中…")
                    .tint(palette.accent)
                    .detailCardSecondaryText()

            case .loaded(let schedules, let isFromCache, let validUntilText, let fetchedAt):
                scheduleContent(
                    schedules: schedules,
                    isFromCache: isFromCache,
                    validUntilText: validUntilText,
                    fetchedAt: fetchedAt
                )

            case .failed(let message, let cachedSchedules, let fetchedAt):
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(palette.warning)

                if let cachedSchedules {
                    scheduleContent(
                        schedules: cachedSchedules,
                        isFromCache: true,
                        validUntilText: nil,
                        fetchedAt: fetchedAt,
                        isOfflineFallback: true
                    )
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
        fetchedAt: Date? = nil,
        isOfflineFallback: Bool = false
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

        if isFullScheduleExpanded == false, nextDepartures.isEmpty == false {
            NextDepartureBannerView(
                title: "次の船便",
                departures: nextDepartures,
                showsTomorrowNote: NextDepartureHelper.isTodayFinished(nextDepartures)
            )
        }

        if visibleSchedules.isEmpty {
            Text("この行き先のダイヤはありません")
                .font(.subheadline)
                .detailCardSecondaryText()
        } else if isFullScheduleExpanded {
            if hasMultipleServiceKinds(in: visibleSchedules) {
                shipTypeLegend
            }

            ForEach(visibleSchedules) { schedule in
                companyBlock(schedule, allSchedules: visibleSchedules)
            }

            collapseScheduleButton
        } else {
            ForEach(visibleSchedules) { schedule in
                companySummaryBlock(schedule, allSchedules: visibleSchedules)
            }

            expandScheduleButton(tripCount: visibleSchedules.reduce(0) { $0 + $1.trips.count })
        }

        if let validUntilText {
            let suffix = IslandCatalog.ferryValidUntilSuffix(for: island.id) ?? ""
            Text("データ有効期限: \(validUntilText)\(suffix)")
                .font(.caption)
                .detailCardSecondaryText()
        }

        if isOfflineFallback {
            Text("代表ダイヤ（参考情報）です。出発前に必ず各社公式サイトでご確認ください。")
                .font(.caption)
                .detailCardSecondaryText()
        } else if let cacheText = CacheAgeText.displayText(fetchedAt: fetchedAt, isFromCache: isFromCache) {
            Text(cacheText)
                .font(.caption)
                .detailCardSecondaryText()
        } else if let sourceNote = IslandCatalog.ferryDataSourceNote(for: island.id) {
            Text(sourceNote)
                .font(.caption)
                .detailCardSecondaryText()
        }
    }

    private func expandScheduleButton(tripCount: Int) -> some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isFullScheduleExpanded = true
            }
        } label: {
            HStack(spacing: 8) {
                Text("全ダイヤを見る（\(tripCount)便）")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer(minLength: 0)

                Image(systemName: "chevron.down")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(palette.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.chipBackground(isSelected: false))
            }
        }
        .buttonStyle(.plain)
        .accessibilityHint("タップで全便のダイヤを表示")
    }

    private var collapseScheduleButton: some View {
        Button {
            withAnimation(.easeInOut(duration: 0.25)) {
                isFullScheduleExpanded = false
            }
        } label: {
            HStack(spacing: 8) {
                Text("全ダイヤを閉じる")
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer(minLength: 0)

                Image(systemName: "chevron.up")
                    .font(.caption.weight(.semibold))
            }
            .foregroundStyle(palette.text)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(palette.chipBackground(isSelected: false))
            }
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private func destinationPicker(destinations: [FerryDestination]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("行き先")
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
        Text("この路線には高速船（日中）と大型客船（夜航）があります。")
            .font(.caption)
            .detailCardSecondaryText()
    }

    private func hasMultipleServiceKinds(in schedules: [FerryCompanySchedule]) -> Bool {
        let kinds = Set(schedules.compactMap(\.serviceKind))
        return kinds.count > 1
    }

    @ViewBuilder
    private func companySummaryBlock(_ schedule: FerryCompanySchedule, allSchedules: [FerryCompanySchedule]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(schedule.company.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            ScheduleOperatorActionButtonsView(
                actions: ScheduleOperatorActionFactory.actions(for: schedule.company)
            )
        }

        if schedule.id != allSchedules.last?.id {
            Divider()
        }
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
                actions: ScheduleOperatorActionFactory.actions(for: schedule.company)
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
        isFullScheduleExpanded = false
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
