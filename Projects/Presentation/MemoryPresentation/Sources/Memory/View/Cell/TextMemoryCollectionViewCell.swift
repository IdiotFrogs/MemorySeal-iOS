//
//  TextMemoryCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 8/19/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

public final class TextMemoryCollectionViewCell: UICollectionViewCell {
    private let textMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "별거 아닌 대화, 별거 아닌 하루가 이렇게 기억에 남을 줄이야. 고마워, 다음에도 함께하자."
        label.numberOfLines = 0
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.textColor = .black
        return label
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setView()
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TextMemoryCollectionViewCell {
    private func setView() {
        backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        layer.cornerRadius = 20
    }
    
    private func addSubviews() {
        addSubview(textMessageLabel)
    }
    
    private func setLayout() {
        textMessageLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.top.leading.trailing.bottom.equalToSuperview().inset(16)
        }
    }
}
