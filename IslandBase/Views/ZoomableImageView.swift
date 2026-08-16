//
//  ZoomableImageView.swift
//  Island Base
//
//  ピンチとダブルタップで拡大できる画像ビュー。
//  開いたときは画像全体が見えるように合わせ、端だけが大きく出ないようにする。
//

import SwiftUI
import UIKit

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    var maximumZoomScale: CGFloat = 4.0
    var doubleTapZoomScale: CGFloat = 2.0

    func makeCoordinator() -> Coordinator {
        Coordinator(
            maximumZoomScale: maximumZoomScale,
            doubleTapZoomScale: doubleTapZoomScale
        )
    }

    func makeUIView(context: Context) -> ZoomableImageScrollView {
        let view = ZoomableImageScrollView()
        view.scrollView.delegate = context.coordinator
        context.coordinator.hostView = view

        // SwiftUI が画像の実寸でビューを広げないようにする
        view.setContentHuggingPriority(.defaultLow, for: .horizontal)
        view.setContentHuggingPriority(.defaultLow, for: .vertical)
        view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        let doubleTap = UITapGestureRecognizer(
            target: context.coordinator,
            action: #selector(Coordinator.handleDoubleTap(_:))
        )
        doubleTap.numberOfTapsRequired = 2
        view.scrollView.addGestureRecognizer(doubleTap)

        return view
    }

    func updateUIView(_ uiView: ZoomableImageScrollView, context: Context) {
        let imageChanged = context.coordinator.image !== image
        context.coordinator.image = image
        context.coordinator.maximumZoomScale = maximumZoomScale
        uiView.setImage(image, resetZoom: imageChanged)
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: ZoomableImageScrollView, context: Context) -> CGSize {
        CGSize(width: proposal.width ?? 0, height: proposal.height ?? 0)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var hostView: ZoomableImageScrollView?
        var image: UIImage?
        var maximumZoomScale: CGFloat
        let doubleTapZoomScale: CGFloat

        init(maximumZoomScale: CGFloat, doubleTapZoomScale: CGFloat) {
            self.maximumZoomScale = maximumZoomScale
            self.doubleTapZoomScale = doubleTapZoomScale
        }

        func viewForZooming(in scrollView: UIScrollView) -> UIView? {
            hostView?.zoomImageView
        }

        func scrollViewDidZoom(_ scrollView: UIScrollView) {
            hostView?.centerZoomedImage()
        }

        func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            scrollView.window?.endEditing(true)
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let hostView else { return }
            let scrollView = hostView.scrollView
            let minScale = scrollView.minimumZoomScale

            if scrollView.zoomScale > minScale * 1.01 {
                scrollView.setZoomScale(minScale, animated: true)
                return
            }

            let location = gesture.location(in: hostView.zoomImageView)
            let targetScale = min(minScale * doubleTapZoomScale, scrollView.maximumZoomScale)
            let width = scrollView.bounds.width / targetScale
            let height = scrollView.bounds.height / targetScale
            let zoomRect = CGRect(
                x: location.x - width / 2,
                y: location.y - height / 2,
                width: width,
                height: height
            )
            scrollView.zoom(to: zoomRect, animated: true)
        }
    }
}

final class ZoomableImageScrollView: UIView {
    let scrollView = UIScrollView()
    let zoomImageView = UIImageView()

    private var currentImage: UIImage?
    // まだ画面サイズに合わせていない（初期 zoomScale は 1.0 のため実寸の端だけ見える）
    private var needsFitToBounds = true
    private var lastBoundsSize: CGSize = .zero

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = true

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bouncesZoom = true
        scrollView.clipsToBounds = true
        addSubview(scrollView)

        zoomImageView.contentMode = .scaleAspectFit
        zoomImageView.isUserInteractionEnabled = true
        zoomImageView.isMultipleTouchEnabled = true
        scrollView.addSubview(zoomImageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds

        if lastBoundsSize != bounds.size {
            lastBoundsSize = bounds.size
            if isShowingWholeImage {
                needsFitToBounds = true
            }
        }

        updateZoomScales()
    }

    func setImage(_ image: UIImage, resetZoom: Bool) {
        let imageChanged = currentImage !== image
        currentImage = image
        zoomImageView.image = image

        if imageChanged {
            zoomImageView.frame = CGRect(origin: .zero, size: image.size)
            needsFitToBounds = true
        }

        if resetZoom {
            needsFitToBounds = true
        }

        updateZoomScales()
    }

    func updateZoomScales() {
        guard let image = currentImage else { return }
        guard scrollView.bounds.width > 1, scrollView.bounds.height > 1 else { return }

        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return }

        var maximumZoomScale: CGFloat = 4.0
        if let coordinator = scrollView.delegate as? ZoomableImageView.Coordinator {
            maximumZoomScale = coordinator.maximumZoomScale
        }

        let widthScale = scrollView.bounds.width / imageSize.width
        let heightScale = scrollView.bounds.height / imageSize.height
        let minScale = min(widthScale, heightScale)
        // 全体表示の4倍、または実寸の大きい方まで拡大できるようにする
        let maxScale = max(minScale * maximumZoomScale, 1.0)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = max(maxScale, minScale + 0.01)

        if needsFitToBounds {
            scrollView.setZoomScale(minScale, animated: false)
            needsFitToBounds = false
        } else if scrollView.zoomScale < minScale {
            scrollView.zoomScale = minScale
        }

        centerZoomedImage()
    }

    func centerZoomedImage() {
        let offsetX = max((scrollView.bounds.width - scrollView.contentSize.width) * 0.5, 0)
        let offsetY = max((scrollView.bounds.height - scrollView.contentSize.height) * 0.5, 0)
        scrollView.contentInset = UIEdgeInsets(
            top: offsetY,
            left: offsetX,
            bottom: offsetY,
            right: offsetX
        )
    }

    private var isShowingWholeImage: Bool {
        abs(scrollView.zoomScale - scrollView.minimumZoomScale) < 0.02
    }
}
