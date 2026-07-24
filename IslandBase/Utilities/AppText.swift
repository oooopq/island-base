//
//  AppText.swift
//  Island Base
//
//  画面まわりの共通文言（日本語 / 英語）
//

import Foundation

enum AppText {
    // ホーム
    case pickRegionOnMap
    case tapPinOrList
    case recentIslands
    case chooseRegion
    case islandCount(Int)
    case openIslandDetail(String)

    // 詳細セクション
    case weather
    case schedule
    case places
    case savedPhotos
    case spots
    case ferry
    case ferryAndHighSpeed
    case flights
    case usefulInfo
    case photoNotes
    case liveCamera
    case destinations
    case current
    case hourlyForecast
    case weeklyWeather
    case humidity
    case windSpeed
    case feelsLikeTemperature(Int)
    case waveHeight
    case significantWaveHeight
    case waveUnavailable
    case waveMax(String)
    case loadingWeather
    case category
    case searchingPlaces
    case loadingSchedule
    case nextFerry
    case nextFlight
    case relatedLinks
    case liveCameraRelatedHeader
    case takePhoto
    case choosePhoto
    case cameraUnavailableTitle
    case cameraUnavailableBody
    case photoLimitTitle
    case phone
    case timetable
    case cancellationsDelays
    case checkStatusBeforeDeparture
    case noPlacesInCategory
    case morePlaces(Int)
    case appleMapsData
    case openWebsite
    case openNavigation
    case openNavigationUnavailable
    case openInGoogleMaps
    case portDistanceSingle(String)
    case portDistanceMultiple(String)
    case userDistanceCaption
    case placeUserDistance(String, String)
    case noTripsForDestination
    case noFlightsForDestination
    case dataValidUntil(String)
    case representativeTimetableNote
    case showAllTrips(Int)
    case hideAllTrips
    case highSpeedAndOvernightNote
    case ferryCheckOfficialSites
    case flightCheckOfficialSites
    case liveCameraFootnote
    case usefulInfoDisclaimer
    case photoNotesDescription(Int)
    case photoNotesLimitReached(Int)
    case photoNotesCount(Int, Int)
    case noPhotoNotesYet
    case photoMemoLabel
    case photoMemoPlaceholder
    case photoMemoDone
    case offlineWeather
    case weatherTimeout
    case offlineFerry
    case offlineFerryFallback
    case offlinePlaces
    case creditsAndSources
    case themeToggleHint
    case languageToggleHint

    // キャッシュ
    case cachePrevious
    case cacheJustNow
    case cacheMinutesAgo(Int)
    case cacheHoursAgo(Int)
    case cacheDaysAgo(Int)

    func string(for language: AppLanguageMode) -> String {
        language.isJapanese ? japanese : english
    }

    private var japanese: String {
        switch self {
        case .pickRegionOnMap:
            return "諸島を選んで、いまの天気・船便を確認"
        case .tapPinOrList:
            return "地図のピンか、下のカードから選ぶ"
        case .recentIslands:
            return "最近見た島"
        case .chooseRegion:
            return "諸島を選ぶ"
        case .islandCount(let count):
            return "\(count)島"
        case .openIslandDetail(let name):
            return "\(name)の詳細を開く"
        case .weather:
            return "天気"
        case .schedule:
            return "ダイヤ"
        case .places:
            return "店舗"
        case .savedPhotos:
            return "写真メモ"
        case .spots:
            return "スポット"
        case .ferry:
            return "船便"
        case .ferryAndHighSpeed:
            return "フェリー・高速船"
        case .flights:
            return "航空便"
        case .usefulInfo:
            return "お役立ち情報"
        case .photoNotes:
            return "写真メモ"
        case .liveCamera:
            return "ライブカメラ"
        case .destinations:
            return "行き先"
        case .current:
            return "現在"
        case .hourlyForecast:
            return "1時間ごとの予報"
        case .weeklyWeather:
            return "週間天気"
        case .humidity:
            return "湿度"
        case .windSpeed:
            return "風速"
        case .feelsLikeTemperature(let celsius):
            return "体感 \(celsius)°C"
        case .waveHeight:
            return "波の高さ"
        case .significantWaveHeight:
            return "有義波高"
        case .waveUnavailable:
            return "取得できません"
        case .waveMax(let value):
            return "最大 \(value) m"
        case .loadingWeather:
            return "天気を取得中…"
        case .category:
            return "カテゴリ"
        case .searchingPlaces:
            return "スポットを検索中…"
        case .loadingSchedule:
            return "ダイヤを取得中…"
        case .nextFerry:
            return "次の船便"
        case .nextFlight:
            return "次の航空便"
        case .relatedLinks:
            return "関連リンク"
        case .liveCameraRelatedHeader:
            return "ライブカメラ・関連リンク"
        case .takePhoto:
            return "撮影"
        case .choosePhoto:
            return "写真を選ぶ"
        case .cameraUnavailableTitle:
            return "カメラを使えません"
        case .cameraUnavailableBody:
            return "この端末ではカメラ撮影が利用できません。"
        case .photoLimitTitle:
            return "保存上限に達しました"
        case .phone:
            return "電話"
        case .timetable:
            return "時刻表"
        case .cancellationsDelays:
            return "欠航・遅延"
        case .checkStatusBeforeDeparture:
            return "出発前に各社公式サイトで運航状況を確認してください。本アプリの時刻は参考ダイヤです。"
        case .noPlacesInCategory:
            return "このカテゴリのスポットが見つかりませんでした"
        case .morePlaces(let count):
            return "ほか \(count) 件"
        case .appleMapsData:
            return "Apple マップのデータを表示しています"
        case .openWebsite:
            return "Webサイト"
        case .openNavigation:
            return "ナビ"
        case .openNavigationUnavailable:
            return "ナビ（利用不可）"
        case .openInGoogleMaps:
            return "Google マップで開く"
        case .portDistanceSingle(let name):
            return "港（\(name)）からの距離・徒歩時間を表示しています"
        case .portDistanceMultiple(let names):
            return "各港（\(names)）からの距離・徒歩時間を表示しています"
        case .userDistanceCaption:
            return "現在地からの距離・徒歩時間を表示しています（近い順）"
        case .placeUserDistance(let distance, let walking):
            return "現在地から \(distance)（\(walking)）"
        case .noTripsForDestination:
            return "この行き先のダイヤはありません"
        case .noFlightsForDestination:
            return "この行き先の便はありません"
        case .dataValidUntil(let text):
            return "データ有効期限: \(text)"
        case .representativeTimetableNote:
            return "代表ダイヤ（参考情報）です。出発前に必ず各社公式サイトでご確認ください。"
        case .showAllTrips(let count):
            return "全ダイヤを見る（\(count)便）"
        case .hideAllTrips:
            return "全ダイヤを閉じる"
        case .highSpeedAndOvernightNote:
            return "この路線には高速船（日中）と大型客船（夜航）があります。"
        case .ferryCheckOfficialSites:
            return "ダイヤ・運航状況は各社公式サイトでご確認ください。"
        case .flightCheckOfficialSites:
            return "ダイヤ・運航状況は各航空会社の公式サイトでご確認ください。"
        case .liveCameraFootnote:
            return "公開配信や公式ページを外部ブラウザで開きます。"
        case .usefulInfoDisclaimer:
            return "※ 電話番号・診療時間は変更されている場合があります。緊急時は119（救急）・118（海上保安庁）"
        case .photoNotesDescription(let max):
            return "港や案内所で撮影した時刻表・案内を、この端末内だけに保存できます。各島あたり最大\(max)枚まで。写真を開くとメモも残せます。"
        case .photoNotesLimitReached(let max):
            return "この島の写真メモは\(max)枚までです。不要な写真を削除すると追加できます。"
        case .photoNotesCount(let count, let max):
            return "\(count)/\(max)枚"
        case .noPhotoNotesYet:
            return "まだ写真メモがありません"
        case .photoMemoLabel:
            return "メモ"
        case .photoMemoPlaceholder:
            return "運賃・便名・注意点などを入力"
        case .photoMemoDone:
            return "完了"
        case .offlineWeather:
            return "天気を取得できませんでした。通信状況をご確認ください。"
        case .weatherTimeout:
            return "天気の取得がタイムアウトしました。しばらくしてから再度お試しください。"
        case .offlineFerry:
            return "電波がないためダイヤを取得できませんでした"
        case .offlineFerryFallback:
            return "ダイヤを取得できませんでした。代表ダイヤ（参考）を表示しています。"
        case .offlinePlaces:
            return "電波がないためスポットを取得できませんでした"
        case .creditsAndSources:
            return "クレジット・出典"
        case .themeToggleHint:
            return "画面の明るさを切り替えます"
        case .languageToggleHint:
            return "表示言語を切り替えます"
        case .cachePrevious:
            return "前回取得したデータを表示中"
        case .cacheJustNow:
            return "たった今取得したデータを表示中"
        case .cacheMinutesAgo(let minutes):
            return "\(minutes)分前に取得したデータを表示中"
        case .cacheHoursAgo(let hours):
            return "\(hours)時間前に取得したデータを表示中"
        case .cacheDaysAgo(let days):
            return "\(days)日前に取得したデータを表示中"
        }
    }

    private var english: String {
        switch self {
        case .pickRegionOnMap:
            return "Pick an island group to check weather and ferries now"
        case .tapPinOrList:
            return "Tap a map pin or a card below"
        case .recentIslands:
            return "Recent islands"
        case .chooseRegion:
            return "Choose a region"
        case .islandCount(let count):
            return "\(count) islands"
        case .openIslandDetail(let name):
            return "Open \(name)"
        case .weather:
            return "Weather"
        case .schedule:
            return "Schedule"
        case .places:
            return "Places"
        case .savedPhotos:
            return "Photos"
        case .spots:
            return "Spots"
        case .ferry:
            return "Ferry"
        case .ferryAndHighSpeed:
            return "Ferry & high-speed boat"
        case .flights:
            return "Flights"
        case .usefulInfo:
            return "Useful info"
        case .photoNotes:
            return "Photo notes"
        case .liveCamera:
            return "Live camera"
        case .destinations:
            return "Destinations"
        case .current:
            return "Now"
        case .hourlyForecast:
            return "Hourly forecast"
        case .weeklyWeather:
            return "7-day forecast"
        case .humidity:
            return "Humidity"
        case .windSpeed:
            return "Wind"
        case .feelsLikeTemperature(let celsius):
            return "Feels like \(celsius)°C"
        case .waveHeight:
            return "Wave height"
        case .significantWaveHeight:
            return "Significant wave height"
        case .waveUnavailable:
            return "Unavailable"
        case .waveMax(let value):
            return "Max \(value) m"
        case .loadingWeather:
            return "Loading weather…"
        case .category:
            return "Category"
        case .searchingPlaces:
            return "Searching places…"
        case .loadingSchedule:
            return "Loading timetable…"
        case .nextFerry:
            return "Next sailing"
        case .nextFlight:
            return "Next flight"
        case .relatedLinks:
            return "Related links"
        case .liveCameraRelatedHeader:
            return "Live camera & links"
        case .takePhoto:
            return "Camera"
        case .choosePhoto:
            return "Choose photo"
        case .cameraUnavailableTitle:
            return "Camera unavailable"
        case .cameraUnavailableBody:
            return "This device can’t take photos with the camera."
        case .photoLimitTitle:
            return "Photo limit reached"
        case .phone:
            return "Call"
        case .timetable:
            return "Timetable"
        case .cancellationsDelays:
            return "Cancellations & delays"
        case .checkStatusBeforeDeparture:
            return "Check each operator’s official site before departure. Times in this app are for reference only."
        case .noPlacesInCategory:
            return "No places found in this category"
        case .morePlaces(let count):
            return "\(count) more"
        case .appleMapsData:
            return "Showing Apple Maps data"
        case .openWebsite:
            return "Website"
        case .openNavigation:
            return "Directions"
        case .openNavigationUnavailable:
            return "Directions unavailable"
        case .openInGoogleMaps:
            return "Open in Google Maps"
        case .portDistanceSingle(let name):
            return "Distance and walking time from \(name)"
        case .portDistanceMultiple(let names):
            return "Distance and walking time from ports (\(names))"
        case .userDistanceCaption:
            return "Showing distance and walking time from your location (nearest first)"
        case .placeUserDistance(let distance, let walking):
            return "\(distance) from you (\(walking))"
        case .noTripsForDestination:
            return "No sailings for this destination"
        case .noFlightsForDestination:
            return "No flights for this destination"
        case .dataValidUntil(let text):
            return "Data valid until: \(text)"
        case .representativeTimetableNote:
            return "Representative timetable for reference. Always check the operator’s official site before departure."
        case .showAllTrips(let count):
            return "Show all sailings (\(count))"
        case .hideAllTrips:
            return "Hide full timetable"
        case .highSpeedAndOvernightNote:
            return "This route has daytime high-speed boats and overnight ferries."
        case .ferryCheckOfficialSites:
            return "Check timetables and service status on each operator’s official site."
        case .flightCheckOfficialSites:
            return "Check timetables and service status on each airline’s official site."
        case .liveCameraFootnote:
            return "Opens public streams or official pages in your browser."
        case .usefulInfoDisclaimer:
            return "※ Phone numbers and hours may change. In emergencies call 119 (ambulance/fire) or 118 (Japan Coast Guard)."
        case .photoNotesDescription(let max):
            return "Save timetable photos and notices on this device only. Up to \(max) per island. Open a photo to add a text note."
        case .photoNotesLimitReached(let max):
            return "This island allows up to \(max) photo notes. Delete one to add another."
        case .photoNotesCount(let count, let max):
            return "\(count)/\(max)"
        case .noPhotoNotesYet:
            return "No photo notes yet"
        case .photoMemoLabel:
            return "Note"
        case .photoMemoPlaceholder:
            return "Fares, sailings, tips…"
        case .photoMemoDone:
            return "Done"
        case .offlineWeather:
            return "Couldn't load weather. Check your connection."
        case .weatherTimeout:
            return "Weather request timed out. Please try again in a moment."
        case .offlineFerry:
            return "Couldn’t load schedules — little or no signal"
        case .offlineFerryFallback:
            return "Couldn’t load schedules. Showing representative timetable for reference."
        case .offlinePlaces:
            return "Couldn’t load places — little or no signal"
        case .creditsAndSources:
            return "Credits & sources"
        case .themeToggleHint:
            return "Toggle light or dark appearance"
        case .languageToggleHint:
            return "Toggle display language"
        case .cachePrevious:
            return "Showing previously saved data"
        case .cacheJustNow:
            return "Showing data fetched just now"
        case .cacheMinutesAgo(let minutes):
            return "Showing data from \(minutes) min ago"
        case .cacheHoursAgo(let hours):
            return "Showing data from \(hours) h ago"
        case .cacheDaysAgo(let days):
            return "Showing data from \(days) d ago"
        }
    }
}
