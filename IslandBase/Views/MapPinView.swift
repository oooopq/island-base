//
//  MapPinView.swift
//  Island Base
//
//  アプリアイコンと同じ深紅のティアドロップピン
//

import SwiftUI

/// 頭の円と先端を一本の輪郭で結ぶ。側面は円の接線なので、頭と尾の境目に線は出ない。
struct MapPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let layout = MapPinGeometry.layout(in: rect)
        let radius = layout.headRadius
        let center = layout.headCenter
        let tip = layout.tip
        let distance = tip.y - center.y
        guard radius > 0, distance > radius else {
            return Path()
        }

        // 先端から円へ引いた接線。α は真下方向と半径のなす角。
        let alpha = acos(Double(radius / distance))
        let leftAngle = Double.pi + alpha
        let rightAngle = Double.pi - alpha

        var path = Path()
        path.move(to: MapPinGeometry.circlePoint(center: center, radius: radius, angle: leftAngle))
        MapPinGeometry.appendCircleArc(
            to: &path,
            center: center,
            radius: radius,
            from: leftAngle,
            to: (2 * Double.pi) + rightAngle
        )
        path.addLine(to: tip)
        path.closeSubpath()
        return path
    }
}

struct MapPinView: View {
    var size: CGSize = CGSize(width: 22, height: 30)

    var body: some View {
        let layout = MapPinGeometry.layout(in: CGRect(origin: .zero, size: size))

        MapPinShape()
            .fill(Self.fill)
            .frame(width: size.width, height: size.height)
            .overlay {
                Circle()
                    .fill(Color.white)
                    .frame(width: layout.holeDiameter, height: layout.holeDiameter)
                    .offset(y: layout.headCenter.y - size.height / 2)
            }
            .compositingGroup()
            .shadow(color: .black.opacity(0.32), radius: 2, y: 1.5)
    }

    /// #C2304F → #A8203F。中間はアイコンの #B8294A と同じ深紅に見える。
    private static let fill = LinearGradient(
        colors: [
            Color(red: 0.761, green: 0.188, blue: 0.310),
            Color(red: 0.659, green: 0.125, blue: 0.247),
        ],
        startPoint: .top,
        endPoint: .bottom
    )
}

private enum MapPinGeometry {
    /// 頭の中心から先端までの距離（頭の半径比）。アイコンのピンに合わせる。
    static let tipDistanceInRadii: CGFloat = 1.5
    /// 白い穴の直径 / 頭の直径。
    static let holeToHead: CGFloat = 0.42

    struct Layout {
        var headCenter: CGPoint
        var headRadius: CGFloat
        var tip: CGPoint
        var holeDiameter: CGFloat
    }

    static func layout(in rect: CGRect) -> Layout {
        // 高さ = 半径 + 先端距離 = 2.5 半径、幅 = 2 半径。
        let aspect = CGFloat(2) / (CGFloat(1) + tipDistanceInRadii)
        let pinWidth = min(rect.width, rect.height * aspect)
        let radius = pinWidth / 2
        let tip = CGPoint(x: rect.midX, y: rect.maxY)
        return Layout(
            headCenter: CGPoint(x: rect.midX, y: tip.y - tipDistanceInRadii * radius),
            headRadius: radius,
            tip: tip,
            holeDiameter: pinWidth * holeToHead
        )
    }

    /// θ = 0 が頭の頂点。角度が増えると右へ回る（y は下向き）。
    static func circlePoint(center: CGPoint, radius: CGFloat, angle: Double) -> CGPoint {
        CGPoint(
            x: center.x + radius * CGFloat(sin(angle)),
            y: center.y - radius * CGFloat(cos(angle))
        )
    }

    static func appendCircleArc(
        to path: inout Path,
        center: CGPoint,
        radius: CGFloat,
        from start: Double,
        to end: Double
    ) {
        var angle = start
        let maxSweep = Double.pi / 2
        while end - angle > 0.000_001 {
            let next = min(angle + maxSweep, end)
            let delta = next - angle
            let startPoint = circlePoint(center: center, radius: radius, angle: angle)
            let endPoint = circlePoint(center: center, radius: radius, angle: next)
            let handle = (4.0 / 3.0) * tan(delta / 4.0) * Double(radius)
            let startTangent = CGPoint(x: CGFloat(cos(angle)), y: CGFloat(sin(angle)))
            let endTangent = CGPoint(x: CGFloat(cos(next)), y: CGFloat(sin(next)))
            path.addCurve(
                to: endPoint,
                control1: CGPoint(
                    x: startPoint.x + CGFloat(handle) * startTangent.x,
                    y: startPoint.y + CGFloat(handle) * startTangent.y
                ),
                control2: CGPoint(
                    x: endPoint.x - CGFloat(handle) * endTangent.x,
                    y: endPoint.y - CGFloat(handle) * endTangent.y
                )
            )
            angle = next
        }
    }
}

#Preview("Light") {
    MapPinPreview()
        .padding(32)
        .background(Color(red: 0.93, green: 0.94, blue: 0.95))
        .preferredColorScheme(.light)
}

#Preview("Dark") {
    MapPinPreview()
        .padding(32)
        .background(Color(red: 0.11, green: 0.13, blue: 0.16))
        .preferredColorScheme(.dark)
}

private struct MapPinPreview: View {
    var body: some View {
        HStack(alignment: .bottom, spacing: 28) {
            MapPinView()
            MapPinView(size: CGSize(width: 16.5, height: 22.5))
            MapPinView(size: CGSize(width: 88, height: 120))
        }
    }
}
