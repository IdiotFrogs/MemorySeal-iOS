//
//  MemoryDescriptionCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

public final class MemoryDescriptionCollectionViewCell: UICollectionViewCell {
    private let memoryTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "첫 여행, 첫 추억"
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
        return label
    }()
    
    private let memoryDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "처음 함께 떠났던 여행의 순간들을 담은 우리의 작은 시간 저장소."
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.addSubViews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MemoryDescriptionCollectionViewCell {
    private func addSubViews() {
        addSubview(memoryTitleLabel)
        addSubview(memoryDescriptionLabel)
    }
    
    private func setLayout() {
        memoryTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        memoryDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(memoryTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
}
