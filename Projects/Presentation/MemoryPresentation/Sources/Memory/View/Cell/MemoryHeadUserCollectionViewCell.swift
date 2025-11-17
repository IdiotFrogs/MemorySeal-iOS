//
//  MemoryHeadUserCollectionViewCell.swift
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

final class MemoryHeadUserCollectionViewCell: UICollectionViewCell {
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
    
    private let headUserLabel: UILabel = {
        let label = UILabel()
        label.text = "방장"
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.backgroundColor = UIColor(hex: "#1A1A1A1A")?.withAlphaComponent(0.1)
        label.textAlignment = .center
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 6
        return label
    }()
    
    private let underLineView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        return view
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

extension MemoryHeadUserCollectionViewCell {
    private func addSubviews() {
        addSubview(userImageView)
        addSubview(userNickNameLabel)
        addSubview(headUserLabel)
        addSubview(underLineView)
    }
    
    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(48)
        }
        
        userNickNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(userImageView.snp.centerY)
            $0.leading.equalTo(userImageView.snp.trailing).offset(8)
        }
        
        headUserLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(24)
            $0.width.equalTo(32)
        }
        
        underLineView.snp.makeConstraints {
            $0.top.equalTo(userImageView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
            $0.bottom.equalToSuperview()
        }
    }
}
