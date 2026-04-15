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

    var tintColor: UIColor {
        switch self {
        case .opened: return .black
        case .closed: return .white
        }
    }
}

public final class FloatingButton: UIButton {
    public var status: FloatingButtonStatus = .closed {
        didSet {
            let openedRotation = CGAffineTransform(rotationAngle: .pi - (.pi / 4))
            let closedRotation = CGAffineTransform.identity
            let rotation = status == .opened ? openedRotation : closedRotation

            UIView.animate(withDuration: 0.3) {
                self.buttonImageView.tintColor = self.status.tintColor
                self.borderImageView.isHidden = self.status == .opened
                self.backgroundColor = self.status == .opened ? .white : .clear
                self.buttonImageView.transform = rotation
            }
        }
    }

    private let borderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.fab.image
        imageView.contentMode = .scaleToFill
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let buttonImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.plusWhite24.image.withRenderingMode(
            .alwaysTemplate
        )
        imageView.tintColor = .white
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
}

extension FloatingButton {
    private func addSubviews() {
        addSubview(borderImageView)
        addSubview(buttonImageView)
    }

    private func setLayout() {
        borderImageView.snp.makeConstraints {
            $0.width.height.equalTo(78)
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(4)
        }

        buttonImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.center.equalToSuperview()
        }
    }
}
