//
//  HomeFloatingButton.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

public final class HomeFloatingButton: UIButton {

    private enum Layout {
        static let iconSize: CGFloat = 24
        static let borderWidth: CGFloat = 3
        static let waveAmplitude: CGFloat = 1.6
        static let waveSpacing: CGFloat = 4.5
    }

    public var status: FloatingButtonStatus = .closed {
        didSet {
            let openedRotation = CGAffineTransform(rotationAngle: .pi - (.pi / 4))
            let closedRotation = CGAffineTransform.identity
            let rotation = status == .opened ? openedRotation : closedRotation

            UIView.animate(withDuration: 0.3) {
                self.buttonImageView.transform = rotation
            }
        }
    }

    private let wavyBackgroundView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.grey5.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.borderWidth
        )
        view.waveAmplitude = Layout.waveAmplitude
        view.waveSpacing = Layout.waveSpacing
        view.isUserInteractionEnabled = false
        return view
    }()

    private let buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.plusWhite24.image
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)

        setInitialValues()
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        wavyBackgroundView.waveCornerRadius = bounds.width / 2
    }
}

// MARK: - Layout

extension HomeFloatingButton {
    private func setInitialValues() {
        backgroundColor = .clear
        clipsToBounds = false
    }

    private func addSubviews() {
        addSubview(wavyBackgroundView)
        addSubview(buttonImageView)
    }

    private func setLayout() {
        wavyBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        buttonImageView.snp.makeConstraints {
            $0.width.height.equalTo(Layout.iconSize)
            $0.center.equalToSuperview()
        }
    }
}
