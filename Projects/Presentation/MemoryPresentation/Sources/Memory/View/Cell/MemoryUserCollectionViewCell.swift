//
//  MemoryUserCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 9/9/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class MemoryUserCollectionViewCell: UICollectionViewCell {
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

extension MemoryUserCollectionViewCell {
    private func addSubviews() {
        addSubview(userImageView)
        addSubview(userNickNameLabel)
    }
    
    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(48)
        }
        
        userNickNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(userImageView.snp.centerY)
            $0.leading.equalTo(userImageView.snp.trailing).offset(8)
        }
    }
}
