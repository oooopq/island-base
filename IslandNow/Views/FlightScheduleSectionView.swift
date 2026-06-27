//
//  FlightScheduleSectionView.swift
//  Island Now
//
//  詳細画面の航空便セクション（与那国線）
//

import SwiftUI

struct FlightScheduleSectionView: View {
    let island: Island
    let schedules: [FlightAirlineSchedule]
    let scheduleNote: String?

    @Environment(\.detailPalette) private var palette
    @State private var selectedDestinationID = FlightRouteHelper.allDestinationsID

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("航空便")
                .font(.headline)

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
                    title: "次の航空便",
                    departures: nextDepartures,
                    showsTomorrowNote: NextDepartureHelper.isTodayFinished(nextDepartures)
                )
            }

            if visibleSchedules.isEmpty {
                Text("この行き先の便はありません")
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

            Text("予約・最新時刻は JAL 公式サイトでご確認ください")
                .font(.caption)
                .detailCardSecondaryText()
        }
        .detailSectionCard()
        .onChange(of: island.id) { _, _ in
            selectedDestinationID = FlightRouteHelper.allDestinationsID
        }
    }

    @ViewBuilder
    private func destinationPicker(destinations: [FlightDestination]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("行き先")
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

    @ViewBuilder
    private func airlineBlock(_ schedule: FlightAirlineSchedule, allSchedules: [FlightAirlineSchedule]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(schedule.airline.name)
                .font(.subheadline)
                .fontWeight(.semibold)

            if let website = schedule.airline.websiteLink {
                OpenURLButton(url: website) {
                    Label("予約・時刻表（JAL）", systemImage: "globe")
                        .font(.subheadline)
                }
            }

            if let phoneURL = schedule.airline.phoneURL {
                OpenURLButton(url: phoneURL) {
                    Label("予約: \(schedule.airline.phoneNumber)", systemImage: "phone.fill")
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
    private func tripRow(_ trip: FlightTrip) -> some View {
        if let route = FlightRouteHelper.parseRoute(trip.routeName) {
            VStack(alignment: .leading, spacing: 6) {
                Text(trip.flightNumber)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(palette.accent)

                HStack(spacing: 6) {
                    Text(route.departure)
                    Image(systemName: "airplane")
                        .font(.caption)
                        .detailCardSecondaryText()
                    Text(route.arrival)
                }
                .font(.subheadline)
                .fontWeight(.medium)

                HStack {
                    Text("\(trip.departureTime) 発")
                    Spacer()
                    Text("\(trip.arrivalTime) 着")
                }
                .font(.caption)
                .detailCardSecondaryText()
            }
        } else {
            HStack {
                Text("\(trip.flightNumber) \(trip.routeName)")
                Spacer()
                Text("\(trip.departureTime) → \(trip.arrivalTime)")
                    .detailCardSecondaryText()
            }
            .font(.subheadline)
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
