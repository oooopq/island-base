//
//  WeatherLoadState.swift
//  Island Base
//
//  天気セクションの表示状態
//

import Foundation

enum WeatherLoadState {
    case loading
    case loaded(WeatherInfo, isFromCache: Bool)
    case failed(message: String, cachedWeather: WeatherInfo?)

    var debugKey: String {
        switch self {
        case .loading:
            return "loading"
        case .loaded(let weather, let isFromCache):
            return "loaded-\(weather.temperatureCelsius)-\(isFromCache)"
        case .failed(let message, _):
            return "failed-\(message)"
        }
    }
}
