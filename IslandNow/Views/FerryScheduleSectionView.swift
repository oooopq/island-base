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

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("船便")
                    .font(.headline)
                Text("フェリー・高速船 / Ferry & High-Speed Boat")
                    .font(.caption)
                    .detailCardSecondaryText()
            }

            switch state {
            case .loading:
                ProgressView("ダイヤを取得中…")
                    .tint(palette.accent)
                    .detailCardSecondaryText()

            case .loaded(let schedules, let isFromCache, let validUntilText):
                scheduleContent(
                    schedules: schedules,
                    isFromCache: isFromCache,
                    validUntilText: validUntilText
                )

            case .failed(let message, let cachedSchedules):
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(palette.warning)

                if let cachedSchedules {
                    scheduleContent(
                        schedules: cachedSchedules,
                        isFromCache: true,
                        validUntilText: nil,
                        isOfflineFallback: true
                    )
                }
            }
        }
        .detailSectionCard()
        .onChange(of: island.id) { _, _ in
            selectedDestinationID = FerryRouteHelper.allDestinationsID
        }
        .onChange(of: stateKey) { _, _ in
            selectedDestinationID = FerryRouteHelper.allDestinationsID
        }
    }

    @ViewBuilder
    private func scheduleContent(
        schedules: [FerryCompanySchedule],
        isFromCache: Bool,
        validUntilText: String?,
        isOfflineFallback: Bool = false
    ) -> some View {
        let destinations = FerryRouteHelper.destinations(in: schedules, currentIslandID: island.id)

        if destinations.isEmpty == false {
            destinationPicker(destinations: destinations)
        }

        let visibleSchedules = filteredSchedules(schedules)
        let nextDepartures = NextDepartureHelper.nextFerryDepartures(
            from: schedules,
            islandID: island.id,
            destinationID: selectedDestinationID
        )

        if nextDepartures.isEmpty == false {
            NextDepartureBannerView(
                title: "次の船便 / Next Departure",
                departures: nextDepartures,
                showsTomorrowNote: NextDepartureHelper.isTodayFinished(nextDepartures)
            )
        }

        if visibleSchedules.isEmpty {
            Text("この行き先のダイヤはありません")
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
            Text("データ有効期限: \(validUntilText)\(suffix)")
                .font(.caption)
                .detailCardSecondaryText()
        }

        if isOfflineFallback {
            Text("代表ダイヤ（参考情報）です。出発前に必ず各社公式サイトでご確認ください。")
                .font(.caption)
                .detailCardSecondaryText()
        } else if isFromCache {
            Text("前回取得したデータを表示中")
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
        VStack(alignment: .leading, spacing: 4) {
            Text("この路線には高速船（日中）と大型客船（夜航）があります。")
                .font(.caption)
                .detailCardSecondaryText()
            Text("Two types of service operate on this route.")
                .font(.caption)
                .detailCardSecondaryText()
        }
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

            if let statusURL = schedule.company.statusPageLink {
                OpenURLButton(url: statusURL) {
                    Label("運航状況 / Service Status", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                .scheduleStatusCallout()
            }

            if let website = schedule.company.websiteLink {
                OpenURLButton(url: website) {
                    Label("時刻表・予約 / Timetable & Booking", systemImage: "globe")
                        .font(.subheadline)
                }
            }

            if let phoneURL = schedule.company.phoneURL {
                OpenURLButton(url: phoneURL) {
                    Label("運航問い合わせ / Call: \(schedule.company.phoneNumber)", systemImage: "phone.fill")
                        .font(.subheadline)
                }
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

    // データが更新されたら行き先選択をリセットする
    private var stateKey: String {
        switch state {
        case .loading:
            return "loading"
        case .loaded(let schedules, let isFromCache, _):
            let tripCount = schedules.reduce(0) { $0 + $1.trips.count }
            return "loaded-\(tripCount)-\(isFromCache)"
        case .failed(let message, let cached):
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
            validUntilText: "2026/06/19"
        )
    )
    .padding()
}
