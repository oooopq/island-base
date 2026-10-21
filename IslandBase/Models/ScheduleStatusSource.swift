//
//  ScheduleStatusSource.swift
//  Island Base
//
//  欠航・遅延確認用の公式リンク（フェリー・航空会社）
//

import Foundation

struct ScheduleStatusSource: Identifiable, Hashable {
    enum Category: String, Hashable {
        case ferry
        case flight
    }

    let id: String
    let name: String
    var nameEnglish: String? = nil
    let statusPageURL: URL
    let phoneNumber: String?
    let category: Category

    func displayName(for language: AppLanguageMode) -> String {
        if language == .english, let nameEnglish, nameEnglish.isEmpty == false {
            return nameEnglish
        }
        return name
    }

    var phoneURL: URL? {
        guard let phoneNumber else { return nil }
        let digits = phoneNumber.filter { $0.isNumber || $0 == "+" }
        guard digits.isEmpty == false else { return nil }
        return URL(string: "tel:\(digits)")
    }
}

enum ScheduleStatusSourceCollector {
    static func fromFerrySchedules(_ schedules: [FerryCompanySchedule]) -> [ScheduleStatusSource] {
        schedules.compactMap { schedule in
            fromFerryCompany(schedule.company)
        }
    }

    static func fromFerryCompanies(_ companies: [FerryCompany]) -> [ScheduleStatusSource] {
        companies.compactMap { fromFerryCompany($0) }
    }

    static func fromFlightSchedules(_ schedules: [FlightAirlineSchedule]) -> [ScheduleStatusSource] {
        schedules.compactMap { schedule in
            fromFlightAirline(schedule.airline)
        }
    }

    static func unique(_ sources: [ScheduleStatusSource]) -> [ScheduleStatusSource] {
        var seen = Set<String>()
        return sources.filter { source in
            seen.insert(source.id).inserted
        }
    }

    private static func fromFerryCompany(_ company: FerryCompany) -> ScheduleStatusSource? {
        guard let statusPageURL = company.statusPageLink else { return nil }
        return ScheduleStatusSource(
            id: statusPageURL.absoluteString,
            name: company.name,
            nameEnglish: company.nameEnglish,
            statusPageURL: statusPageURL,
            phoneNumber: company.phoneNumber,
            category: .ferry
        )
    }

    private static func fromFlightAirline(_ airline: FlightAirline) -> ScheduleStatusSource? {
        guard let statusPageURL = airline.statusPageLink else { return nil }
        return ScheduleStatusSource(
            id: statusPageURL.absoluteString,
            name: airline.name,
            nameEnglish: airline.nameEnglish,
            statusPageURL: statusPageURL,
            phoneNumber: airline.phoneNumber,
            category: .flight
        )
    }
}
