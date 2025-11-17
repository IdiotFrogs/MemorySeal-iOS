//
//  AddMemberCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 10/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

final class AddMemberCollectionViewCell: UICollectionViewCell {
    
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.layer.cornerRadius = 17
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let userNickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "나는야 유저 유저!"
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        return label
    }()
    
    private let refusalButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            "거절",
            for: .normal
        )
        button.setTitleColor(
            DesignSystemAsset.ColorAssests.grey4.color,
            for: .normal
        )
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let acceptButton: UIButton = {
        let button = UIButton()
        button.setTitle(
            "수락",
            for: .normal
        )
        button.setTitleColor(
            DesignSystemAsset.ColorAssests.primaryDark.color,
            for: .normal
        )
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        button.layer.cornerRadius = 8
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddMemberCollectionViewCell {
    private func addSubviews() {
        addSubview(userImageView)
        addSubview(acceptButton)
        addSubview(refusalButton)
        addSubview(userNickNameLabel)
    }
    
    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview()
            $0.width.height.equalTo(48)
        }
        
        acceptButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalTo(49)
        }
        
        refusalButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.trailing.equalTo(acceptButton.snp.leading).offset(-8)
            $0.height.equalTo(32)
            $0.width.equalTo(49)
        }
        
        userNickNameLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalTo(userImageView.snp.trailing).offset(8)
            $0.trailing.equalTo(refusalButton.snp.leading).offset(-8)
            $0.width.greaterThanOrEqualTo(142)
        }
    }
}
