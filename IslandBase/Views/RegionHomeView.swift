//
//  RegionHomeView.swift
//  Island Base
//
//  起動画面：日本地図から諸島郡を選ぶ
//

import MapKit
import SwiftUI

struct RegionHomeView: View {
    @Environment(\.detailPalette) private var palette
    @Environment(LastSelectedIslandStore.self) private var lastSelectedIslandStore
    @Environment(AppLanguageStore.self) private var languageStore
    @Environment(\.navigateToRegion) private var navigateToRegion
    @State private var cameraPosition: MapCameraPosition = RegionMapSupport.japanHomeCameraPosition()

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                header
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    .padding(.bottom, 12)

                japanMap
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .layoutPriority(1)

                regionCoverCarousel
                    .padding(.top, 12)
                    .padding(.bottom, 16)
            }
            .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
        }
        .background(homeBackground)
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                NavigationLink {
                    ImageCreditsView()
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(palette.secondaryText)
                }
                .accessibilityLabel(languageStore.t(.creditsAndSources))
            }

            ToolbarItem(placement: .topBarTrailing) {
                HStack(spacing: 8) {
                    AppLanguageToggleButton()
                    AppThemeToggleButton()
                }
            }
        }
        .navigationDestination(for: String.self) { regionID in
            if let region = IslandRegionCatalog.region(for: regionID) {
                RegionIslandsView(region: region)
            }
        }
        .navigationDestination(for: Island.self) { island in
            IslandDetailView(island: island)
        }
        .onAppear {
            applyJapanHomeCamera()
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 14) {
            if lastSelectedIslandStore.islands.isEmpty == false {
                recentIslandsSection
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(languageStore.t(.pickRegionOnMap))
                    .font(.subheadline)
                    .foregroundStyle(palette.secondaryText)
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)

                Text(languageStore.t(.tapPinOrList))
                    .font(.caption)
                    .foregroundStyle(palette.secondaryText.opacity(0.85))
                    .lineLimit(2)
                    .minimumScaleFactor(0.85)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var recentIslandsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageStore.t(.recentIslands))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(palette.secondaryText)

            HStack(spacing: 12) {
                ForEach(lastSelectedIslandStore.islands) { island in
                    LastSelectedIslandShortcutView(island: island)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    private var japanMap: some View {
        ZStack(alignment: .topLeading) {
            Map(
                position: $cameraPosition,
                bounds: RegionMapSupport.japanMapCameraBounds,
                interactionModes: []
            ) {
                ForEach(IslandRegionCatalog.homeMapMainRegions) { region in
                    Annotation(
                        "",
                        coordinate: RegionMapSupport.homeMapPinCoordinate(for: region),
                        anchor: JapanRegionMarkerView.annotationAnchor(for: region)
                    ) {
                        JapanRegionMarkerView(region: region) {
                            navigateToRegion(region.id)
                        }
                        .accessibilityLabel(
                            "\(region.displayName(for: languageStore.mode)) \(languageStore.t(.islandCount(IslandCatalog.islandCount(forRegionID: region.id))))"
                        )
                        .accessibilityAddTraits(.isButton)
                    }
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))

            VStack(alignment: .leading, spacing: 8) {
                ForEach(IslandRegionCatalog.homeMapInsetRegions) { region in
                    HomeMapInsetMapView(region: region)
                }
            }
            .padding(10)
        }
        .onAppear {
            applyJapanHomeCamera()
        }
        .task {
            // レイアウト確定のたびに、本図の基準画角へ戻す
            applyJapanHomeCamera()
            try? await Task.sleep(for: .milliseconds(50))
            applyJapanHomeCamera()
            try? await Task.sleep(for: .milliseconds(200))
            applyJapanHomeCamera()
        }
        .frame(maxWidth: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(palette.cardBorder, lineWidth: 1)
        }
        .padding(.horizontal, 16)
        .frame(minHeight: 200, maxHeight: .infinity)
    }

    private func applyJapanHomeCamera() {
        cameraPosition = RegionMapSupport.japanHomeCameraPosition()
    }

    /// 横スクロール専用の固定エリア。縦スクロールと競合しない
    private var regionCoverCarousel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(languageStore.t(.chooseRegion))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundStyle(palette.secondaryText)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(IslandCatalog.regions) { region in
                        NavigationLink(value: region.id) {
                            RegionCoverCardView(region: region)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            // 地図・見出しと同じく、スクロールビュー自体を左右にインセットする
            // （中の padding だけだと先頭カードが画面端に張り付く端末がある）
            .padding(.horizontal, 16)
        }
    }

    private var homeBackground: some View {
        ZStack {
            Color(red: 0.06, green: 0.08, blue: 0.12)
            LinearGradient(
                colors: [
                    palette.cardBackground.opacity(0.35),
                    palette.cardBackground.opacity(0.85),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}

private struct HomeMapInsetMapView: View {
    let region: IslandRegion

    @Environment(\.detailPalette) private var palette
    @Environment(AppLanguageStore.self) private var languageStore
    @Environment(\.navigateToRegion) private var navigateToRegion
    @State private var cameraPosition: MapCameraPosition

    init(region: IslandRegion) {
        self.region = region
        _cameraPosition = State(
            initialValue: RegionMapSupport.homeMapInsetCameraPosition(for: region)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(languageStore.t(.homeMapInsetCaption))
                .font(.system(size: 9, weight: .semibold))
                .foregroundStyle(palette.secondaryText)
                .padding(.horizontal, 4)

            Map(
                position: $cameraPosition,
                bounds: RegionMapSupport.homeMapInsetCameraBounds(for: region),
                interactionModes: []
            ) {
                Annotation(
                    "",
                    coordinate: RegionMapSupport.homeMapPinCoordinate(for: region),
                    anchor: JapanRegionMarkerView.annotationAnchor(for: region, compact: true)
                ) {
                    JapanRegionMarkerView(region: region, usesCompactLabel: true) {
                        navigateToRegion(region.id)
                    }
                    .accessibilityLabel(
                        "\(region.displayName(for: languageStore.mode)) \(languageStore.t(.islandCount(IslandCatalog.islandCount(forRegionID: region.id))))"
                    )
                    .accessibilityAddTraits(.isButton)
                }
            }
            .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
            .frame(width: 172, height: 140)
            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .strokeBorder(palette.cardBorder, lineWidth: 1.5)
            }
            .onAppear {
                cameraPosition = RegionMapSupport.homeMapInsetCameraPosition(for: region)
            }
        }
        .padding(6)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .accessibilityElement(children: .combine)
        .accessibilityAddTraits(.isButton)
        .onTapGesture {
            navigateToRegion(region.id)
        }
    }
}

private struct JapanRegionMarkerView: View {
    let region: IslandRegion
    var usesCompactLabel: Bool = false
    var onSelect: () -> Void

    @Environment(AppLanguageStore.self) private var languageStore

    private let pinWidth: CGFloat = 22
    private let pinHeight: CGFloat = 30
    private let pinStroke = Color(red: 0.70, green: 0.03, blue: 0.05)

    static func annotationAnchor(for region: IslandRegion, compact: Bool = false) -> UnitPoint {
        let canvas = markerCanvas(for: region, compact: compact)
        return UnitPoint(
            x: canvas.tip.x / canvas.size.width,
            y: canvas.tip.y / canvas.size.height
        )
    }

    fileprivate struct MarkerCanvas {
        var size: CGSize
        var tip: CGPoint
    }

    fileprivate static func markerCanvas(for region: IslandRegion, compact: Bool) -> MarkerCanvas {
        let offsetX = region.homeMap.labelOffsetX
        let offsetY = region.homeMap.labelOffsetY
        let edge: CGFloat = compact ? 36 : 48
        let labelPad: CGFloat = compact ? 44 : 64
        let width = abs(offsetX) + edge + labelPad
        let height = abs(offsetY) + edge + 26
        let tipX = offsetX >= 0 ? edge : width - edge
        let tipY = offsetY >= 0 ? edge : height - edge
        return MarkerCanvas(
            size: CGSize(width: width, height: height),
            tip: CGPoint(x: tipX, y: tipY)
        )
    }

    var body: some View {
        let offset = CGSize(
            width: region.homeMap.labelOffsetX,
            height: region.homeMap.labelOffsetY
        )
        let canvas = Self.markerCanvas(for: region, compact: usesCompactLabel)
        let tip = canvas.tip

        ZStack(alignment: .topLeading) {
            Path { path in
                path.move(to: CGPoint(x: tip.x, y: tip.y - 3))
                path.addLine(
                    to: CGPoint(x: tip.x + offset.width, y: tip.y + offset.height)
                )
            }
            .stroke(
                Color.primary.opacity(0.70),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round)
            )
            .allowsHitTesting(false)

            HomeMapPinShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 1.00, green: 0.15, blue: 0.17),
                            Color(red: 0.86, green: 0.02, blue: 0.04),
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay {
                    HomeMapPinShape()
                        .stroke(pinStroke, lineWidth: 1.2)
                }
                .overlay(alignment: .top) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 9, height: 9)
                        .padding(.top, 5)
                }
                .frame(width: pinWidth, height: pinHeight)
                .shadow(color: .black.opacity(0.32), radius: 2, y: 1.5)
                .position(x: tip.x, y: tip.y - pinHeight / 2)
                .onTapGesture(perform: onSelect)

            label
                .position(x: tip.x + offset.width, y: tip.y + offset.height)
                .onTapGesture(perform: onSelect)
        }
        .frame(width: canvas.size.width, height: canvas.size.height)
    }

    private var label: some View {
        Text(region.mapLabel(for: languageStore.mode))
            .font(.system(size: usesCompactLabel ? 10 : 11, weight: .semibold))
            .foregroundStyle(Color.primary.opacity(0.92))
            .lineLimit(1)
            .fixedSize()
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(.ultraThinMaterial, in: Capsule())
            .overlay {
                Capsule()
                    .strokeBorder(Color.black.opacity(0.14), lineWidth: 0.6)
            }
            .shadow(color: .black.opacity(0.16), radius: 1.5, y: 1)
    }
}

/// アプリアイコン中央の赤いドロップ型ピン
private struct HomeMapPinShape: Shape {
    func path(in rect: CGRect) -> Path {
        let stemX = rect.midX
        let circleSide = min(rect.width, rect.height * 0.64)
        let circle = CGRect(
            x: stemX - circleSide / 2,
            y: rect.minY + 0.4,
            width: circleSide,
            height: circleSide
        )

        var path = Path()
        path.addEllipse(in: circle)
        path.move(to: CGPoint(x: circle.minX + circleSide * 0.16, y: circle.midY + circleSide * 0.18))
        path.addQuadCurve(
            to: CGPoint(x: stemX, y: rect.maxY),
            control: CGPoint(x: circle.minX + circleSide * 0.12, y: circle.maxY + circleSide * 0.12)
        )
        path.addQuadCurve(
            to: CGPoint(x: circle.maxX - circleSide * 0.16, y: circle.midY + circleSide * 0.18),
            control: CGPoint(x: circle.maxX - circleSide * 0.12, y: circle.maxY + circleSide * 0.12)
        )
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationStack {
        RegionHomeView()
    }
    .environment(AppThemeStore())
    .environment(AppLanguageStore())
    .environment(LastSelectedIslandStore())
    .environment(\.detailPalette, DetailCardPalette.dark)
}
