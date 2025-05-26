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
    
    var backgroundColor: UIColor {
        switch self {
        case .opened:
            return .white
        case .closed:
            return DesignSystemAsset.ColorAssests.primaryNormal.color
        }
    }
    
    var tintColor: UIColor {
        switch self {
        case .opened:
            return .black
        case .closed:
            return .white
        }
    }
}

public final class FloatingButton: UIButton {
    public var status: FloatingButtonStatus = .closed {
        didSet {
            let openedRotationAngle: CGAffineTransform = CGAffineTransform(
                rotationAngle: .pi - (.pi / 4)
            )
            let closedRotationAngle: CGAffineTransform = CGAffineTransform.identity
            
            let roatation = status == .opened ? openedRotationAngle : closedRotationAngle

            UIView.animate(withDuration: 0.3) {
                self.buttonImageView.tintColor = self.status.tintColor
                self.backgroundColor = self.status.backgroundColor
                self.buttonImageView.transform = roatation
            }
        }
    }
    
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
        
        self.backgroundColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension FloatingButton {
    private func addSubviews() {
        addSubview(buttonImageView)
    }
    
    private func setLayout() {
        buttonImageView.snp.makeConstraints {
            $0.width.height.equalTo(24)
            $0.center.equalToSuperview()
        }
    }
}
