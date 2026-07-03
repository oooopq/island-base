//
//  IslandArtIntro.swift
//  Island Now
//
//  島詳細画面を開いたときのアート演出（任意）
//

import CoreGraphics
import Foundation

struct IslandArtIntro {
    /// 画面いっぱいの写真を保つ秒数
    let holdSeconds: Double
    /// ズームアウトにかける秒数
    let zoomOutSeconds: Double
    /// 開始時の拡大率（1より大きいほど「寄り」から始まる）
    let startScale: CGFloat

    /// 写真フルスクリーン → ズームアウトで通常画面へ
    static let fullscreenZoomOut = IslandArtIntro(
        holdSeconds: 0.4,
        zoomOutSeconds: 0.9,
        startScale: 1.4
    )
}
