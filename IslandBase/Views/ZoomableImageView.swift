//
//  ZoomableImageView.swift
//  Island Base
//
//  ピンチとダブルタップで拡大できる画像ビュー
//

import SwiftUI
import UIKit

struct ZoomableImageView: UIViewRepresentable {
    let image: UIImage
    var maximumZoomScale: CGFloat = 3.0
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
        uiView.setImage(image, resetZoom: imageChanged)
    }

    final class Coordinator: NSObject, UIScrollViewDelegate {
        weak var hostView: ZoomableImageScrollView?
        var image: UIImage?

        let maximumZoomScale: CGFloat
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

            if scrollView.zoomScale > scrollView.minimumZoomScale * 1.01 {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
                return
            }

            let location = gesture.location(in: hostView.zoomImageView)
            let targetScale = min(
                scrollView.minimumZoomScale * doubleTapZoomScale,
                scrollView.maximumZoomScale
            )
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
    private var maximumZoomScale: CGFloat = 3.0

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear

        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = .clear
        scrollView.contentInsetAdjustmentBehavior = .never
        scrollView.bouncesZoom = true
        addSubview(scrollView)

        zoomImageView.contentMode = .scaleAspectFit
        zoomImageView.isUserInteractionEnabled = true
        scrollView.addSubview(zoomImageView)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame = bounds
        updateZoomScales(resetZoom: false)
    }

    func setImage(_ image: UIImage, resetZoom: Bool) {
        currentImage = image
        zoomImageView.image = image
        updateZoomScales(resetZoom: resetZoom)
    }

    func updateZoomScales(resetZoom: Bool) {
        guard let image = currentImage else { return }
        guard scrollView.bounds.width > 0, scrollView.bounds.height > 0 else { return }

        let imageSize = image.size
        guard imageSize.width > 0, imageSize.height > 0 else { return }

        if let coordinator = scrollView.delegate as? ZoomableImageView.Coordinator {
            maximumZoomScale = coordinator.maximumZoomScale
        }

        zoomImageView.frame = CGRect(origin: .zero, size: imageSize)

        let widthScale = scrollView.bounds.width / imageSize.width
        let heightScale = scrollView.bounds.height / imageSize.height
        let minScale = min(widthScale, heightScale)

        scrollView.minimumZoomScale = minScale
        scrollView.maximumZoomScale = max(minScale * maximumZoomScale, minScale + 0.01)

        if resetZoom || scrollView.zoomScale < minScale {
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
}
