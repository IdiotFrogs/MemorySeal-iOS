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
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        return imageView
    }()

    private let userNickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "나는야 유저 유저!"
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        return label
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
        addSubview(userNickNameLabel)
    }

    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        acceptButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.equalTo(49)
        }

        userNickNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(userImageView.snp.trailing).offset(12)
            $0.trailing.lessThanOrEqualTo(acceptButton.snp.leading).offset(-16)
        }
    }
}
