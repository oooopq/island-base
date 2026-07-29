//
//  WeatherIconView.swift
//  Island Base
//
//  天候に合わせたアイコン表示
//

import SwiftUI

struct WeatherIconView: View {
    let weatherCode: Int?
    let condition: String
    var iconSize: CGFloat = 24

    init(weatherCode: Int? = nil, condition: String, iconSize: CGFloat = 24) {
        self.weatherCode = weatherCode
        self.condition = condition
        self.iconSize = iconSize
    }

    var body: some View {
        Image(systemName: WeatherIconMapper.systemImage(weatherCode: weatherCode, condition: condition))
            .font(.system(size: iconSize))
            .foregroundStyle(WeatherIconMapper.color(weatherCode: weatherCode, condition: condition))
            .frame(width: iconSize + 8, height: iconSize + 8)
    }
}

#Preview {
    HStack(spacing: 16) {
        WeatherIconView(weatherCode: 0, condition: "晴れ", iconSize: 32)
        WeatherIconView(weatherCode: 61, condition: "雨", iconSize: 32)
        WeatherIconView(weatherCode: 3, condition: "くもり", iconSize: 32)
    }
}
