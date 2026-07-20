//
//  WeatherIconView.swift
//  Island Base
//
//  天候に合わせたアイコン表示
//

import SwiftUI

struct WeatherIconView: View {
    let condition: String
    var iconSize: CGFloat = 24

    var body: some View {
        Image(systemName: WeatherIconMapper.systemImage(for: condition))
            .font(.system(size: iconSize))
            .foregroundStyle(WeatherIconMapper.color(for: condition))
            .frame(width: iconSize + 8, height: iconSize + 8)
    }
}

#Preview {
    HStack(spacing: 16) {
        WeatherIconView(condition: "晴れ", iconSize: 32)
        WeatherIconView(condition: "雨", iconSize: 32)
        WeatherIconView(condition: "くもり", iconSize: 32)
    }
}
