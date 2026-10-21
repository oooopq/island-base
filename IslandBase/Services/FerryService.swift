//
//  FerryService.swift
//  Island Base
//
//  OTTOPのGTFSから本物のフェリーダイヤを取得する
//

import Foundation

struct FerryFetchResult: Codable {
    let schedules: [FerryCompanySchedule]
    let validUntilText: String?
    /// 端末に保存した取得時刻（古いキャッシュには無い）
    let fetchedAt: Date?

    init(
        schedules: [FerryCompanySchedule],
        validUntilText: String?,
        fetchedAt: Date? = nil
    ) {
        self.schedules = schedules
        self.validUntilText = validUntilText
        self.fetchedAt = fetchedAt
    }
}

private struct ParsedFeedResult: Sendable {
    let schedule: FerryCompanySchedule?
    let validUntilText: String?
}

struct FerryService {
    private let cacheKeyPrefix = "ferry_cache_v2_"
    /// GTFS は当日分だけ残す。Pages の定期ダイヤは別キーにし、同じ日判定で消さない
    private let pagesCacheKeyPrefix = "ferry_pages_cache_v1_"
    private static let pagesSession: URLSession = {
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = NetworkTimeout.weatherPagesSeconds
        config.timeoutIntervalForResource = NetworkTimeout.weatherPagesSeconds + 2
        config.waitsForConnectivity = false
        return URLSession(configuration: config)
    }()
    private static let japanCalendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "Asia/Tokyo") ?? .current
        return calendar
    }()

    func fetchSchedules(for island: Island) async throws -> FerryFetchResult {
        let feeds = feeds(for: island)
        var schedules: [FerryCompanySchedule] = []
        var validUntilTexts: [String] = []
        var anyFeedSucceeded = false

        for feed in feeds {
            do {
                try Task.checkCancellation()

                let url = feed.downloadURL
                let (data, response) = try await URLSession.shared.data(from: url)

                guard let httpResponse = response as? HTTPURLResponse,
                      httpResponse.statusCode == 200 else {
                    continue
                }

                // 実データは最大約27KB。5MBを超えるものは異常として扱う
                guard data.count <= 5 * 1024 * 1024 else { continue }

                let parsed = try await parseFeed(data: data, islandID: island.id, feed: feed)
                anyFeedSucceeded = true

                if let validUntil = parsed.validUntilText {
                    validUntilTexts.append(validUntil)
                }

                if let schedule = parsed.schedule {
                    schedules.append(schedule)
                }
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                // 1社分の取得に失敗しても、他社のダイヤは表示する
                continue
            }
        }

        if schedules.isEmpty {
            guard anyFeedSucceeded else {
                throw FerryServiceError.networkUnavailable
            }

            let emptyResult = FerryFetchResult(
                schedules: [],
                validUntilText: validUntilTexts.max(),
                fetchedAt: Date()
            )
            saveCache(emptyResult, for: island.id)
            return emptyResult
        }

        let result = FerryFetchResult(
            schedules: schedules,
            validUntilText: validUntilTexts.max(),
            fetchedAt: Date()
        )
        saveCache(result, for: island.id)
        return result
    }

    /// GitHub Pages の時刻表 JSON。失敗時は保存しない
    func fetchPagesSchedules(for island: Island) async throws -> FerryFetchResult {
        guard let profile = IslandCatalog.profile(for: island),
              let fileName = profile.ferryPagesFileName,
              fileName == FerryPagesTimetable.allowedFileName,
              let company = profile.sampleFerrySchedules.first?.company else {
            throw FerryServiceError.badResponse
        }

        let url = try makePagesURL(fileName: fileName)
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalCacheData
        request.timeoutInterval = NetworkTimeout.weatherPagesSeconds

        let (data, response) = try await Self.pagesSession.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw FerryServiceError.badResponse
        }

        let timetable: FerryPagesIslandTimetable
        do {
            timetable = try FerryPagesTimetable.decode(
                data: data,
                islandID: island.id,
                company: company
            )
        } catch {
            throw FerryServiceError.badResponse
        }

        let result = FerryFetchResult(
            schedules: timetable.schedules,
            validUntilText: nil,
            fetchedAt: Date()
        )
        savePagesCache(result, for: island.id)
        return result
    }

    /// Pages 時刻表の端末キャッシュ。日をまたいでも残す（鮮度は JSON の fetchedAt で判断する）
    func cachedPagesSchedules(for islandID: String) -> FerryFetchResult? {
        let key = pagesCacheKeyPrefix + islandID
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        guard let result = try? JSONDecoder().decode(FerryFetchResult.self, from: data) else {
            UserDefaults.standard.removeObject(forKey: key)
            return nil
        }

        return result
    }

    /// 当日（日本時間）に取得したキャッシュのみ返す。前日の便は表示しない
    func cachedSchedules(for islandID: String) -> FerryFetchResult? {
        let key = cacheKeyPrefix + islandID
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return nil
        }

        guard let result = try? JSONDecoder().decode(FerryFetchResult.self, from: data) else {
            UserDefaults.standard.removeObject(forKey: key)
            return nil
        }

        guard isFetchedTodayJapan(result.fetchedAt) else {
            UserDefaults.standard.removeObject(forKey: key)
            return nil
        }

        return result
    }

    private func isFetchedTodayJapan(_ fetchedAt: Date?) -> Bool {
        guard let fetchedAt else { return false }
        return Self.japanCalendar.isDate(fetchedAt, inSameDayAs: Date())
    }

    private func feeds(for island: Island) -> [FerryGTFSFeed] {
        IslandCatalog.profile(for: island)?.ferryGTFSFeeds ?? []
    }

    // ZIP解凍・CSVパースはメインスレッド外で実行する
    private func parseFeed(data: Data, islandID: String, feed: FerryGTFSFeed) async throws -> ParsedFeedResult {
        try await Task.detached(priority: .userInitiated) {
            let parser = GTFSFerryParser()
            let files = try GTFSZipReader.extractTextFiles(from: data)
            let trips = parser.parseTrips(from: files, islandID: islandID)
            let validUntilText = parser.validUntilText(from: files)

            let schedule: FerryCompanySchedule?
            if trips.isEmpty {
                schedule = nil
            } else {
                schedule = FerryCompanySchedule(
                    id: "\(islandID)-\(feed.id)",
                    company: feed.company,
                    trips: trips
                )
            }

            return ParsedFeedResult(schedule: schedule, validUntilText: validUntilText)
        }.value
    }

    private func saveCache(_ result: FerryFetchResult, for islandID: String) {
        guard let data = try? JSONEncoder().encode(result) else { return }
        UserDefaults.standard.set(data, forKey: cacheKeyPrefix + islandID)
    }

    private func savePagesCache(_ result: FerryFetchResult, for islandID: String) {
        guard let data = try? JSONEncoder().encode(result) else { return }
        UserDefaults.standard.set(data, forKey: pagesCacheKeyPrefix + islandID)
    }

    private func makePagesURL(fileName: String) throws -> URL {
        guard fileName == FerryPagesTimetable.allowedFileName else {
            throw FerryServiceError.badResponse
        }
        let block = FerryPagesTimetable.halfDayBlockString()
        let urlString = "\(AppLegalInfo.ferryCacheBaseURL)/\(fileName).json?h=\(block)"
        guard let url = URL(string: urlString) else {
            throw FerryServiceError.badResponse
        }
        return url
    }
}

enum FerryServiceError: Error {
    case badResponse
    /// GTFS の取得・解析にすべて失敗した（通信不良など）
    case networkUnavailable
}
