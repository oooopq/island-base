//
//  FerryPagesTimetableTests.swift
//
//  XCTest ターゲットは無いので、Foundation だけで動く確認用スクリプト。
//  Xcode のアプリ本体には入らない（IslandBase フォルダの外）。
//
//  swiftc -parse ではなく実行する:
//  swiftc -o /tmp/ferry-pages-tests \
//    IslandBase/Models/AppLanguageMode.swift \
//    IslandBase/Utilities/AppURL.swift \
//    IslandBase/Models/FerryServiceKind.swift \
//    IslandBase/Models/FerryCompany.swift \
//    IslandBase/Models/FerryTrip.swift \
//    IslandBase/Models/FerryCompanySchedule.swift \
//    IslandBase/Services/FerryPagesTimetable.swift \
//    tests/FerryPagesTimetableTests.swift
//  /tmp/ferry-pages-tests docs/ferry/kutsuna.json
//

import Foundation

private var failures = 0

private func expect(_ condition: Bool, _ message: String) {
    if condition == false {
        failures += 1
        fputs("FAIL \(message)\n", stderr)
    }
}

private func expectThrows(
    _ message: String,
    _ body: () throws -> Void
) {
    do {
        try body()
        failures += 1
        fputs("FAIL \(message) — did not throw\n", stderr)
    } catch {
        return
    }
}

private let company = FerryCompany(
    name: "中島汽船",
    nameEnglish: "Nakajima Kisen",
    websiteURL: "https://www.pref.ehime.jp/site/chuyo/4786.html",
    phoneNumber: "089-997-1221"
)

private func decodeFixture(_ json: String, islandID: String = "nakajima") throws -> FerryPagesIslandTimetable {
    let data = Data(json.utf8)
    return try FerryPagesTimetable.decode(data: data, islandID: islandID, company: company)
}

private func testRealFile() throws {
    let path = CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "docs/ferry/kutsuna.json"
    let data = try Data(contentsOf: URL(fileURLWithPath: path))
    expect(data.count <= FerryPagesTimetable.maxResponseBytes, "real file is within 256KB")

    let timetable = try FerryPagesTimetable.decode(data: data, islandID: "nakajima", company: company)
    let trips = timetable.schedules.flatMap(\.trips)
    expect(trips.count == 38, "nakajima has 38 trips, got \(trips.count)")
    expect(company.websiteURL == "https://www.pref.ehime.jp/site/chuyo/4786.html", "company URL stays the fixed profile value")
    expect(company.phoneNumber == "089-997-1221", "phone stays 089-997-1221")

    let suspended = trips.filter { $0.hasScheduledTimes == false }
    expect(suspended.isEmpty == false, "suspended trips are kept")
    expect(suspended.allSatisfy { $0.note?.isEmpty == false }, "suspended trips keep a note")
    expect(suspended.allSatisfy { $0.departureTime.isEmpty && $0.arrivalTime.isEmpty }, "suspended trips have no clock times")

    let timed = trips.filter(\.hasScheduledTimes)
    expect(timed.count + suspended.count == trips.count, "every trip is timed or note-only")
    expect(suspended.count == 10, "nakajima has 10 suspended trips, got \(suspended.count)")
    expect(FerryPagesTimetable.scheduledTripCount(in: timetable.schedules) == 28, "card counts timed trips only, got \(FerryPagesTimetable.scheduledTripCount(in: timetable.schedules))")
    expect(timed.allSatisfy { $0.departureIslandID == "nakajima" || $0.arrivalIslandID == "nakajima" }, "nakajima trips touch nakajima")
    expect(
        suspended.allSatisfy {
            FerryPagesTimetable.localizedSuspensionNote($0.note ?? "", language: .english) == "Suspended until further notice (since Feb 1, 2025)"
        },
        "known suspension notes translate"
    )

    let kinds = Set(timetable.schedules.compactMap(\.serviceKind))
    expect(kinds.contains(.ferry) && kinds.contains(.highSpeedBoat), "nakajima has ferry and high-speed headings")
    expect(
        FerryPagesTimetable.showsHighSpeedAndOvernightLegend(timetable.schedules.map(\.serviceKind)) == false,
        "ferry plus high-speed does not show the overnight legend"
    )

    let nogutsuna = try FerryPagesTimetable.decode(data: data, islandID: "nogutsunajima", company: company)
    let nogutsunaTrips = nogutsuna.schedules.flatMap(\.trips)
    expect(nogutsunaTrips.isEmpty == false, "nogutsunajima has trips")
    expect(
        nogutsunaTrips.allSatisfy {
            $0.departureIslandID == "nogutsunajima" || $0.arrivalIslandID == "nogutsunajima"
        },
        "野忽那 is not classified as nakajima"
    )
    expect(
        nogutsunaTrips.contains { $0.departureIslandID == "nakajima" || $0.arrivalIslandID == "nakajima" } == false,
        "nogutsunajima trips do not point at nakajima"
    )

    expectThrows("gogoshima is not in the file") {
        _ = try FerryPagesTimetable.decode(data: data, islandID: "gogoshima", company: company)
    }
}

private func testNullTimesDoNotFailDecode() throws {
    let json = """
    {"schemaVersion":1,"fetchedAt":"2026-10-21T01:20:23Z","source":{"name":"x","url":"http://evil.example/phish"},"islands":{"nakajima":[{"id":"s","line":"東線","kind":"highspeed","trips":[{"from":"高浜","to":"大浦","departure":null,"arrival":null,"note":"2025年2月1日から当面の間運休"},{"from":"大浦","to":"三津浜","departure":"05:40","arrival":"06:40","note":null}]}]}}
    """
    let timetable = try decodeFixture(json)
    let trips = timetable.schedules.flatMap(\.trips)
    expect(trips.count == 2, "null times do not drop the whole document, got \(trips.count)")
    expect(trips[0].hasScheduledTimes == false, "first trip has no times")
    expect(trips[0].note == "2025年2月1日から当面の間運休", "note is kept")
    expect(trips[0].arrivalIslandID == "nakajima", "大浦 is nakajima")
    expect(trips[0].departureIslandID == nil, "高浜 is mainland")
    expect(trips[1].departureTime == "05:40" && trips[1].arrivalTime == "06:40", "timed trip is kept")
    expect(timetable.schedules[0].showsOperatorActions == false, "pages schedules leave links to the existing section")
    expect(timetable.schedules[0].serviceKind == .highSpeedBoat, "highspeed maps to the existing kind")
    expect(timetable.schedules[0].lineLabel == "東線", "line label is kept")
}

private func testSchemaSizeAndMalformed() throws {
    let wrong = """
    {"schemaVersion":2,"fetchedAt":"2026-10-21T01:20:23Z","islands":{"nakajima":[]}}
    """
    expectThrows("schemaVersion 2") {
        _ = try decodeFixture(wrong)
    }

    var oversized = Data(count: FerryPagesTimetable.maxResponseBytes + 1)
    oversized[0] = 0x7B
    expectThrows("over 256KB") {
        _ = try FerryPagesTimetable.decode(data: oversized, islandID: "nakajima", company: company)
    }

    expectThrows("malformed") {
        _ = try FerryPagesTimetable.decode(data: Data("[]".utf8), islandID: "nakajima", company: company)
    }
}

private func testTruncation() throws {
    var trips: [String] = []
    for index in 0..<101 {
        let minute = index % 60
        trips.append("""
        {"from":"大浦","to":"三津浜","departure":"08:\(String(format: "%02d", minute))","arrival":"09:\(String(format: "%02d", minute))","note":null}
        """)
    }
    let json = """
    {"schemaVersion":1,"fetchedAt":"2026-10-21T01:20:23Z","islands":{"nakajima":[{"id":"s","line":"東線","kind":"ferry","trips":[\(trips.joined(separator: ","))]}]}}
    """
    let timetable = try decodeFixture(json)
    let count = timetable.schedules.flatMap(\.trips).count
    expect(count == 100, "truncates to 100 trips, got \(count)")
    expect(timetable.schedules[0].serviceKind == .ferry, "ferry maps to the ferry kind")
    expect(FerryPagesTimetable.scheduledTripCount(in: timetable.schedules) == 100, "timed ferry trips are all counted")
}

private func testStaleAndBlock() {
    let fetched = ISO8601DateFormatter().date(from: "2026-10-21T01:20:23Z")!
    expect(FerryPagesTimetable.isStale(sourceUpdatedAt: fetched, now: fetched.addingTimeInterval(3 * 24 * 60 * 60)) == false, "exactly 3 days is not stale")
    expect(FerryPagesTimetable.isStale(sourceUpdatedAt: fetched, now: fetched.addingTimeInterval(3 * 24 * 60 * 60 + 1)), "older than 3 days is stale")

    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
    let morning = calendar.date(from: DateComponents(year: 2026, month: 10, day: 21, hour: 11, minute: 59))!
    let noon = calendar.date(from: DateComponents(year: 2026, month: 10, day: 21, hour: 12))!
    expect(FerryPagesTimetable.halfDayBlockString(for: morning) == "2026102100", "morning block is 00")
    expect(FerryPagesTimetable.halfDayBlockString(for: noon) == "2026102112", "noon block is 12")

    let stamp = FerryPagesTimetable.displayTimestamp(fetched, language: .japanese)
    expect(stamp == "10月21日 10:20", "JST stamp got \(stamp)")
}

private func testKindLabelsAndLegendStayPut() {
    expect(FerryServiceKind.ferry.titleJapanese == "フェリー", "ferry title")
    expect(FerryServiceKind.ferry.titleEnglish == "Ferry", "ferry english title")
    expect(FerryServiceKind.ferry.shortLabel(for: .japanese) == "フェリー", "next-departure label")
    expect(FerryServiceKind.ferry.shortLabel(for: .english) == "Ferry", "english next-departure label")
    expect(FerryServiceKind.highSpeedBoat.titleJapanese == "高速船", "high-speed title unchanged")
    expect(FerryServiceKind.highSpeedBoat.titleEnglish == "High-Speed Boat", "high-speed english title unchanged")
    expect(FerryServiceKind.highSpeedBoat.shortLabel(for: .english) == "High-Speed Boat", "high-speed label unchanged")
    expect(FerryServiceKind.highSpeedBoat.descriptionJapanese == "日中運航 · 約2〜3時間 · 指定席", "high-speed description unchanged")
    expect(FerryServiceKind.highSpeedBoat.descriptionEnglish == "Day service · About 2–3 hours · Reserved seats", "high-speed english description unchanged")
    expect(FerryServiceKind.overnightFerry.titleJapanese == "大型客船（夜航）", "overnight title unchanged")
    expect(FerryServiceKind.overnightFerry.titleEnglish == "Overnight Ferry", "overnight english title unchanged")
    expect(FerryServiceKind.overnightFerry.descriptionJapanese == "夜出港 · 翌朝着 · 2等寝台あり", "overnight description unchanged")
    expect(FerryServiceKind.overnightFerry.descriptionEnglish == "Evening departure · Arrives next morning · Sleeper berths available", "overnight english description unchanged")
    expect(FerryServiceKind.allCases.count == 3, "only the ferry case was added")

    expect(FerryPagesTimetable.showsHighSpeedAndOvernightLegend([.highSpeedBoat, .overnightFerry]), "izu and goto pair still shows the legend")
    expect(FerryPagesTimetable.showsHighSpeedAndOvernightLegend([.ferry, .highSpeedBoat]) == false, "kutsuna pair hides the legend")
    expect(FerryPagesTimetable.showsHighSpeedAndOvernightLegend([.highSpeedBoat]) == false, "one kind hides the legend")
    expect(FerryPagesTimetable.showsHighSpeedAndOvernightLegend([nil, .highSpeedBoat]) == false, "yaeyama nil kind hides the legend")
}

private func testNotesAndMainlandPorts() {
    let known = "2025年2月1日から当面の間運休"
    expect(
        FerryPagesTimetable.localizedSuspensionNote(known, language: .english) == "Suspended until further notice (since Feb 1, 2025)",
        "date is taken from the note"
    )
    expect(FerryPagesTimetable.localizedSuspensionNote(known, language: .japanese) == known, "japanese note stays")
    expect(
        FerryPagesTimetable.localizedSuspensionNote("当面の間運休", language: .english) == "Suspended until further notice",
        "phrase without a date"
    )
    expect(
        FerryPagesTimetable.localizedSuspensionNote("荒天のため当面の間運休", language: .english) == "荒天のため当面の間運休",
        "unknown surrounding text stays japanese"
    )
    expect(
        FerryPagesTimetable.localizedSuspensionNote("2025年2月31日から当面の間運休", language: .english) == "2025年2月31日から当面の間運休",
        "invalid date stays japanese"
    )
    expect(
        FerryPagesTimetable.localizedSuspensionNote("欠航", language: .english) == "欠航",
        "unknown note stays japanese"
    )

    expect(FerryPagesTimetable.localizedMainlandPortName("三津浜", language: .english) == "Mitsuhama Port (三津浜)", "mitsuhama")
    expect(FerryPagesTimetable.localizedMainlandPortName("高浜", language: .english) == "Takahama Port (高浜)", "takahama")
    expect(FerryPagesTimetable.localizedMainlandPortName("三津浜", language: .japanese) == nil, "japanese place names stay in the caller")
    expect(FerryPagesTimetable.localizedMainlandPortName("大浦港", language: .english) == nil, "island ports are unchanged")
    expect(FerryPagesTimetable.localizedMainlandPortName("北条", language: .english) == nil, "hojo is unchanged")
    expect(FerryPagesTimetable.localizedLine("東線", language: .english) == "East route", "east route label")
    expect(FerryPagesTimetable.localizedLine("西線", language: .japanese) == "西線", "west route label")
}

private func testLegacyGTFSCacheStillDecodes() throws {
    let json = """
    {"id":"ishigaki-1","company":{"name":"安栄観光株式会社","websiteURL":"https://aneikankou.co.jp/","phoneNumber":"0980-83-0055"},"trips":[{"id":"t1","routeName":"石垣港 → 竹富港","departureTime":"08:30","arrivalTime":"09:10"}]}
    """
    let schedule = try JSONDecoder().decode(FerryCompanySchedule.self, from: Data(json.utf8))
    expect(schedule.trips[0].note == nil, "old trip note is nil")
    expect(schedule.trips[0].departureIslandID == nil, "old trip has no explicit island id")
    expect(schedule.trips[0].hasScheduledTimes, "old trip still has times")
    expect(schedule.lineLabel == nil, "old schedule has no line label")
    expect(schedule.sourceUpdatedAt == nil, "old schedule has no pages timestamp")
    expect(schedule.showsOperatorActions == nil, "old schedule still shows operator buttons")
    expect(schedule.serviceKind == nil, "missing service kind stays nil")
}

@main
struct FerryPagesTimetableTestRunner {
    static func main() throws {
        try testRealFile()
        try testNullTimesDoNotFailDecode()
        try testSchemaSizeAndMalformed()
        try testTruncation()
        testStaleAndBlock()
        testKindLabelsAndLegendStayPut()
        testNotesAndMainlandPorts()
        try testLegacyGTFSCacheStillDecodes()
        if failures > 0 {
            fputs("\(failures) failed\n", stderr)
            exit(1)
        }
        print("ok")
    }
}
