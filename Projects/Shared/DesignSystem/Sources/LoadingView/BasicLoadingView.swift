//
//  BasicLoadingView.swift
//  DesignSystem
//
//  Created by 선민재 on 6/30/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class BasicLoadingView: UIView {
    // MARK: - Constant
    private enum Metric {
        static let logoWidth: CGFloat = 28
        static let logoHeight: CGFloat = 32
        static let spacing: CGFloat = 14
        static let riseOffset: CGFloat = 12
        static let cycleDuration: CFTimeInterval = 2.1
        static let dimAlpha: CGFloat = 0.5
    }

    private let animationKey: String = "sequence"

    // MARK: - UI
    private let logoImageViews: [UIImageView] = (0..<3).map { _ in
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.loadingLogo.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = Metric.spacing
        return stackView
    }()

    // MARK: - Init
    public init() {
        super.init(frame: .zero)

        self.backgroundColor = UIColor.black.withAlphaComponent(Metric.dimAlpha)
        self.isUserInteractionEnabled = true

        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    private func addSubviews() {
        logoImageViews.forEach { stackView.addArrangedSubview($0) }
        addSubview(stackView)
    }

    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        logoImageViews.forEach { imageView in
            imageView.snp.makeConstraints {
                $0.width.equalTo(Metric.logoWidth)
                $0.height.equalTo(Metric.logoHeight)
            }
        }
    }

    // MARK: - Animation
    public func startAnimating() {
        let stagger = Metric.cycleDuration / Double(logoImageViews.count)
        let beginTime = CACurrentMediaTime()

        for (index, imageView) in logoImageViews.enumerated() {
            imageView.layer.removeAnimation(forKey: animationKey)
            imageView.layer.opacity = 0

            let opacity = CAKeyframeAnimation(keyPath: "opacity")
            opacity.values = [0, 1, 1, 0, 0]
            opacity.keyTimes = [0, 0.08, 0.3, 0.38, 1.0]

            let translateY = CAKeyframeAnimation(keyPath: "transform.translation.y")
            translateY.values = [Metric.riseOffset, 0, 0]
            translateY.keyTimes = [0, 0.15, 1.0]

            let group = CAAnimationGroup()
            group.animations = [opacity, translateY]
            group.duration = Metric.cycleDuration
            group.repeatCount = .infinity
            group.beginTime = beginTime + Double(index) * stagger
            group.timingFunction = CAMediaTimingFunction(name: .easeOut)
            imageView.layer.add(group, forKey: animationKey)
        }
    }

    public func stopAnimating() {
        logoImageViews.forEach {
            $0.layer.removeAnimation(forKey: animationKey)
            $0.layer.opacity = 1.0
        }
    }

    // MARK: - Show
    @discardableResult
    public static func show(on view: UIView) -> BasicLoadingView {
        view.subviews.compactMap { $0 as? BasicLoadingView }.forEach { $0.removeFromSuperview() }

        let loadingView = BasicLoadingView()
        view.addSubview(loadingView)
        loadingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        loadingView.layoutIfNeeded()
        loadingView.startAnimating()

        return loadingView
    }

    public func hide() {
        stopAnimating()
        removeFromSuperview()
    }
}
