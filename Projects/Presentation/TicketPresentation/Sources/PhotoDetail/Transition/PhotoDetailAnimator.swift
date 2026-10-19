//
//  PhotoDetailAnimator.swift
//  TicketPresentation
//
//  Created by 선민재 on 10/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

final class PhotoDetailAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    private enum Metric {
        static let duration: TimeInterval = 0.32
    }

    private let isPresenting: Bool
    private let source: PhotoDetailTransitionSource

    init(isPresenting: Bool, source: PhotoDetailTransitionSource) {
        self.isPresenting = isPresenting
        self.source = source
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Metric.duration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if isPresenting {
            animatePresenting(using: transitionContext)
        } else {
            animateDismissing(using: transitionContext)
        }
    }
}

// MARK: - Presenting

extension PhotoDetailAnimator {
    private func animatePresenting(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView

        guard let viewer = transitionContext.viewController(forKey: .to) as? PhotoDetailViewController,
              let viewerView = transitionContext.view(forKey: .to)
        else {
            transitionContext.completeTransition(false)
            return
        }

        viewerView.frame = transitionContext.finalFrame(for: viewer)
        container.addSubview(viewerView)
        viewerView.layoutIfNeeded()

        let sourceImageView = source.imageView(at: viewer.currentPhotoIndex)

        guard let sourceImageView,
              let image = sourceImageView.image,
              let startFrame = sourceImageView.superview?.convert(sourceImageView.frame, to: container)
        else {
            fadeIn(viewerView, using: transitionContext)
            return
        }

        let movingImageView = makeMovingImageView(
            image: image,
            frame: startFrame,
            contentMode: sourceImageView.contentMode,
            cornerRadius: sourceImageView.layer.cornerRadius
        )
        container.addSubview(movingImageView)

        viewerView.alpha = 0
        viewer.setPhotoHidden(true)
        sourceImageView.alpha = 0

        let endFrame = viewer.currentPhotoFrame(in: container) ?? startFrame

        UIView.animate(
            withDuration: Metric.duration,
            delay: 0,
            usingSpringWithDamping: 0.9,
            initialSpringVelocity: 0,
            options: [.curveEaseInOut]
        ) {
            viewerView.alpha = 1
            movingImageView.frame = endFrame
            movingImageView.layer.cornerRadius = 0
            movingImageView.contentMode = .scaleAspectFit
        } completion: { _ in
            movingImageView.removeFromSuperview()
            viewer.setPhotoHidden(false)
            sourceImageView.alpha = 1
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK: - Dismissing

extension PhotoDetailAnimator {
    private func animateDismissing(using transitionContext: UIViewControllerContextTransitioning) {
        let container = transitionContext.containerView

        guard let viewer = transitionContext.viewController(forKey: .from) as? PhotoDetailViewController,
              let viewerView = transitionContext.view(forKey: .from)
        else {
            transitionContext.completeTransition(false)
            return
        }

        let sourceImageView = source.imageView(at: viewer.currentPhotoIndex)
        let startFrame = viewer.currentPhotoFrame(in: container)

        guard let sourceImageView,
              let startFrame,
              let image = viewer.currentPhotoImage(),
              let endFrame = sourceImageView.superview?.convert(sourceImageView.frame, to: container)
        else {
            fadeOut(viewerView, using: transitionContext)
            return
        }

        let movingImageView = makeMovingImageView(
            image: image,
            frame: startFrame,
            contentMode: .scaleAspectFit,
            cornerRadius: 0
        )
        container.addSubview(movingImageView)

        viewer.setPhotoHidden(true)
        sourceImageView.alpha = 0

        UIView.animate(
            withDuration: Metric.duration,
            delay: 0,
            options: [.curveEaseInOut]
        ) {
            viewerView.alpha = 0
            movingImageView.frame = endFrame
            movingImageView.contentMode = sourceImageView.contentMode
            movingImageView.layer.cornerRadius = sourceImageView.layer.cornerRadius
        } completion: { _ in
            movingImageView.removeFromSuperview()
            sourceImageView.alpha = 1
            viewerView.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK: - Helper

extension PhotoDetailAnimator {
    private func makeMovingImageView(
        image: UIImage,
        frame: CGRect,
        contentMode: UIView.ContentMode,
        cornerRadius: CGFloat
    ) -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.frame = frame
        imageView.contentMode = contentMode
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = cornerRadius
        return imageView
    }

    private func fadeIn(_ view: UIView, using transitionContext: UIViewControllerContextTransitioning) {
        view.alpha = 0
        UIView.animate(withDuration: Metric.duration) {
            view.alpha = 1
        } completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }

    private func fadeOut(_ view: UIView, using transitionContext: UIViewControllerContextTransitioning) {
        UIView.animate(withDuration: Metric.duration) {
            view.alpha = 0
        } completion: { _ in
            view.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}

// MARK: - TransitioningDelegate

final class PhotoDetailTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private let source: PhotoDetailTransitionSource

    init(source: PhotoDetailTransitionSource) {
        self.source = source
    }

    func animationController(
        forPresented presented: UIViewController,
        presenting: UIViewController,
        source: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return PhotoDetailAnimator(isPresenting: true, source: self.source)
    }

    func animationController(
        forDismissed dismissed: UIViewController
    ) -> UIViewControllerAnimatedTransitioning? {
        return PhotoDetailAnimator(isPresenting: false, source: source)
    }
}
