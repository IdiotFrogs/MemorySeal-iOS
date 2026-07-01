//
//  CreateTicketLoadingView.swift
//  DesignSystem
//
//  Created by 선민재 on 6/30/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class CreateTicketLoadingView: UIView {
    // MARK: - Constant
    private enum Metric {
        static let messageTopOffset: CGFloat = 100
        static let skeletonTopOffset: CGFloat = 24
        static let skeletonWidthRatio: CGFloat = 0.685
        static let skeletonAspectRatio: CGFloat = 278.0 / 226.0
        static let lineHeightMultiple: CGFloat = 1.4
    }

    private let shimmerAnimationKey: String = "shimmer"

    // MARK: - UI
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
        return label
    }()

    private let skeletonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketLoadingSkeleton.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let shimmerView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.isUserInteractionEnabled = false
        return view
    }()

    private let shimmerGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.white.withAlphaComponent(1).cgColor,
            UIColor.white.withAlphaComponent(1).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor,
            UIColor.white.withAlphaComponent(0).cgColor
        ]
        layer.locations = [0, 0.4, 0.567, 1.0]
        layer.startPoint = CGPoint(x: 0, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 0.5)
        return layer
    }()

    // MARK: - Init
    public init() {
        super.init(frame: .zero)

        self.backgroundColor = .white
        self.isUserInteractionEnabled = true

        setMessage()
        addSubviews()
        setLayout()

        shimmerView.layer.addSublayer(shimmerGradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        shimmerGradientLayer.frame = CGRect(
            x: -shimmerView.bounds.width * 1.8,
            y: 0,
            width: shimmerView.bounds.width * 3,
            height: shimmerView.bounds.height
        )
    }

    // MARK: - Message
    private func setMessage() {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.lineHeightMultiple = Metric.lineHeightMultiple

        messageLabel.attributedText = NSAttributedString(
            string: "티켓을 만드는중이에요\n잠시만 기다려주세요",
            attributes: [
                .paragraphStyle: paragraphStyle,
                .font: DesignSystemFontFamily.Pretendard.bold.font(size: 20),
                .foregroundColor: UIColor.black
            ]
        )
    }

    // MARK: - Layout
    private func addSubviews() {
        addSubview(messageLabel)
        addSubview(skeletonImageView)
        skeletonImageView.addSubview(shimmerView)
    }

    private func setLayout() {
        messageLabel.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(Metric.messageTopOffset)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        skeletonImageView.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(Metric.skeletonTopOffset)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(Metric.skeletonWidthRatio)
            $0.height.equalTo(skeletonImageView.snp.width).multipliedBy(Metric.skeletonAspectRatio)
        }

        shimmerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }

    // MARK: - Animation
    public func startAnimating() {
        let width = shimmerView.bounds.width

        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.values = [0, 0.35 * width, 0.55 * width, 1.8 * width]
        animation.keyTimes = [0, 0.2, 0.6, 1.0]
        animation.duration = 1.0
        animation.repeatCount = .infinity
        shimmerGradientLayer.add(animation, forKey: shimmerAnimationKey)
    }

    public func stopAnimating() {
        shimmerGradientLayer.removeAnimation(forKey: shimmerAnimationKey)
    }

    // MARK: - Show
    @discardableResult
    public static func show(on view: UIView) -> CreateTicketLoadingView {
        view.subviews.compactMap { $0 as? CreateTicketLoadingView }.forEach { $0.removeFromSuperview() }

        let loadingView = CreateTicketLoadingView()
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
