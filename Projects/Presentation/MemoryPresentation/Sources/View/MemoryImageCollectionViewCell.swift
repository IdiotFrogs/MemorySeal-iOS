//
//  MemoryImageCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class MemoryImageCollectionViewCell: UICollectionViewCell {
    private let memoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .gray
        imageView.image = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        return imageView
    }()
    
    private let closeMemoryButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 16
        button.backgroundColor = .white
        button.setImage(DesignSystemAsset.ImageAssets.iconXmarkBlack16.image, for: .normal)
        return button
    }()
    
    private let imageBlurView: UIVisualEffectView = {
        let view = UIVisualEffectView()
        view.effect = UIBlurEffect(style: .regular)
        view.alpha = 0.5
        return view
    }()
    
    private let memoryEndDateLabel: UILabel = {
        let label = UILabel()
        label.text = "D-60"
        label.textColor = .white
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 40)
        return label
    }()
    
    private let memoryPeriodLabel: UILabel = {
        let label = UILabel()
        label.text = "2025. 02. 20. (목) ~ 2025. 04. 20. (일)"
        label.textColor = .white
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubViews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MemoryImageCollectionViewCell {
    private func addSubViews() {
        addSubview(memoryImageView)
        addSubview(closeMemoryButton)
        addSubview(imageBlurView)
        addSubview(memoryPeriodLabel)
        addSubview(memoryEndDateLabel)
    }
    
    private func setLayout() {
        memoryImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        closeMemoryButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(52)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(32)
        }
        
        imageBlurView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(memoryImageView.snp.bottom)
            $0.height.equalTo(110)
        }
        
        memoryPeriodLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(20)
        }
        
        memoryEndDateLabel.snp.makeConstraints {
            $0.bottom.equalTo(memoryPeriodLabel.snp.top)
            $0.leading.equalToSuperview().inset(20)
        }
    }
}
