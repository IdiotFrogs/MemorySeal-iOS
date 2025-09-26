//
//  UserListCollectionViewCell.swift
//  MessageListPresentation
//
//  Created by 선민재 on 9/22/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

final class UserListCollectionViewCell: UICollectionViewCell {
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        return imageView
    }()
    
    private let userNickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "뿡빵삥"
        label.textAlignment = .center
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UserListCollectionViewCell {
    func configure(userNickName: String) {
        userNickNameLabel.text = userNickName
    }
}

extension UserListCollectionViewCell {
    private func addSubviews() {
        addSubview(userProfileImageView)
        addSubview(userNickNameLabel)
    }
    
    private func setLayout() {
        userProfileImageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.height.equalTo(80)
        }
        
        userNickNameLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImageView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
