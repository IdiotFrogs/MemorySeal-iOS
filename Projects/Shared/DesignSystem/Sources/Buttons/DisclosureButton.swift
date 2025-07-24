//
//  DisclosureButton.swift
//  DesignSystem
//
//  Created by 선민재 on 7/25/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class DisclosureButton: UIButton {
    private let titleTextLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        return label
    }()
    
    private let rightArrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.greyRightArrowImage.image
        return imageView
    }()
    
    public init(
        title: String,
        titleColor: UIColor = DesignSystemAsset.ColorAssests.grey5.color
    ) {
        titleTextLabel.text = title
        titleTextLabel.textColor = titleColor
        super.init(frame: .zero)
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DisclosureButton {
    private func addSubviews() {
        addSubview(titleTextLabel)
        addSubview(rightArrowImageView)
    }
    
    private func setLayout() {
        titleTextLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }
        
        rightArrowImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(16)
        }
    }
}
