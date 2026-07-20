//
//  FlightScheduleSectionView.swift
//  Island Base
//
//  詳細画面の航空便セクション（与那国線）
//

import SwiftUI

struct FlightScheduleSectionView: View {
    let island: Island
    let schedules: [FlightAirlineSchedule]
    let scheduleNote: String?

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
    @State private var selectedDestinationID = FlightRouteHelper.allDestinationsID

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ScheduleTransportHeaderView(
                kind: .flight,
                title: languageStore.t(.flights)
            )

            let destinations = FlightRouteHelper.destinations(in: schedules, currentIslandID: island.id)

            if destinations.isEmpty == false {
                destinationPicker(destinations: destinations)
            }

            let visibleSchedules = filteredSchedules(schedules)
            let nextDepartures = NextDepartureHelper.nextFlightDepartures(
                from: schedules,
                islandID: island.id,
                destinationID: selectedDestinationID
            )

            if nextDepartures.isEmpty == false {
                NextDepartureBannerView(
                    title: languageStore.t(.nextFlight),
                    departures: nextDepartures,
                    showsTomorrowNote: NextDepartureHelper.isTodayFinished(nextDepartures),
                    accentColor: ScheduleTransportKind.flight.accentColor
                )
            }

            if visibleSchedules.isEmpty {
                Text(languageStore.t(.noFlightsForDestination))
                    .font(.subheadline)
                    .detailCardSecondaryText()
            } else {
                ForEach(visibleSchedules) { schedule in
                    airlineBlock(schedule, allSchedules: visibleSchedules)
                }
            }

            if let scheduleNote {
                Text(scheduleNote)
                    .font(.caption)
                    .detailCardSecondaryText()
            }

            if let bookingNote = bookingFootnote(from: visibleSchedules) {
                Text(bookingNote)
                    .font(.caption)
                    .detailCardSecondaryText()
            }
        }
        .detailSectionCard()
        .onChange(of: island.id) { _, _ in
            selectedDestinationID = FlightRouteHelper.allDestinationsID
        }
    }

    @ViewBuilder
    private func destinationPicker(destinations: [FlightDestination]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageStore.t(.destinations))
                .font(.subheadline)
                .detailCardSecondaryText()

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    destinationChip(
                        title: "すべて",
                        isSelected: selectedDestinationID == FlightRouteHelper.allDestinationsID
                    ) {
                        selectedDestinationID = FlightRouteHelper.allDestinationsID
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

    private func filteredSchedules(_ schedules: [FlightAirlineSchedule]) -> [FlightAirlineSchedule] {
        schedules.compactMap { schedule in
            let trips = FlightRouteHelper.filteredTrips(
                schedule.trips,
                destinationID: selectedDestinationID,
                currentIslandID: island.id
            )
            guard trips.isEmpty == false else { return nil }
            return FlightAirlineSchedule(id: schedule.id, airline: schedule.airline, trips: trips)
        }
    }

    private func bookingFootnote(from schedules: [FlightAirlineSchedule]) -> String? {
        let names = Array(Set(schedules.map(\.airline.name))).sorted()
        guard names.isEmpty == false else { return nil }
        if names.count == 1 {
            return "予約・最新時刻は \(names[0]) 公式サイトでご確認ください"
        }
        return "予約・最新時刻は各航空会社の公式サイトでご確認ください"
    }

    @ViewBuilder
    private func airlineBlock(_ schedule: FlightAirlineSchedule, allSchedules: [FlightAirlineSchedule]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(schedule.airline.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            ScheduleOperatorActionButtonsView(
                actions: ScheduleOperatorActionFactory.actions(for: schedule.airline, language: languageStore.mode)
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
    private func tripRow(_ trip: FlightTrip) -> some View {
        if let route = FlightRouteHelper.parseRoute(trip.routeName) {
            VStack(alignment: .leading, spacing: 8) {
                Text(trip.flightNumber)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(ScheduleTransportKind.flight.accentColor)

                HStack(spacing: 6) {
                    Text(route.departure)
                    Image(systemName: "airplane")
                        .font(.caption)
                        .foregroundStyle(ScheduleTransportKind.flight.accentColor)
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
                Text("\(trip.flightNumber) \(trip.routeName)")
                    .font(.subheadline)
                    .fontWeight(.medium)

                ScheduleDepartureArrivalView(
                    departureTime: trip.departureTime,
                    arrivalTime: trip.arrivalTime
                )
            }
        }
    }
}

#Preview {
    FlightScheduleSectionView(
        island: IslandCatalog.islands.first { $0.id == "yonaguni" } ?? IslandCatalog.islands[0],
        schedules: IslandCatalog.profile(for: "yonaguni")?.flightSchedules ?? [],
        scheduleNote: IslandCatalog.profile(for: "yonaguni")?.flightScheduleNote
    )
    .padding()
}
