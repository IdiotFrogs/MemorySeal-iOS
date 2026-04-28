//
//  FloatingButton.swift
//  HomePresentation
//
//  Created by 선민재 on 5/26/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public enum FloatingButtonStatus {
    case opened
    case closed
}

public final class FloatingButton: UIButton {

    private enum Layout {
        static let circleSize: CGFloat = 79
        static let iconSize: CGFloat = 28
        static let strokeLineWidth: CGFloat = 4
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
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: UIColor(hex: "#29A047") ?? DesignSystemAsset.ColorAssests.primaryDark.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.isUserInteractionEnabled = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.25
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        return view
    }()

    private let buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.plusWhite24.image
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        clipsToBounds = false
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        wavyBackgroundView.waveCornerRadius = wavyBackgroundView.bounds.width / 2
        wavyBackgroundView.layer.shadowPath = UIBezierPath(
            ovalIn: wavyBackgroundView.bounds
        ).cgPath
    }
}

extension FloatingButton {
    private func addSubviews() {
        addSubview(wavyBackgroundView)
        addSubview(buttonImageView)
    }

    private func setLayout() {
        wavyBackgroundView.snp.makeConstraints {
            $0.width.height.equalTo(Layout.circleSize)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(4)
        }

        buttonImageView.snp.makeConstraints {
            $0.width.height.equalTo(Layout.iconSize)
            $0.center.equalTo(wavyBackgroundView)
        }
    }
}
