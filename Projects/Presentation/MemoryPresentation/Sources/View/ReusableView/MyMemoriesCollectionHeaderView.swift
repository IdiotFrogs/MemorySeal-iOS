//
//  MyMemoriesCollectionHeaderView.swift
//  MemoryPresentation
//
//  Created by 선민재 on 8/19/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

final class MyMemoriesCollectionHeaderView: UICollectionReusableView {
    enum Status {
        case message
        case member
        
        var title: String {
            switch self {
            case .member:
                return "맴버"
            case .message:
                return "추억 메시지"
            }
        }
    }
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        return label
    }()
    
    private let memberCountLabel: UILabel = {
        let label = UILabel()
        label.text = "7"
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        return label
    }()
    
    private let seeOtherMemoryMessageButton: UIButton = {
        let button = UIButton()
        button.setImage(DesignSystemAsset.ImageAssets.rightArrowImage.image, for: .normal)
        return button
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        self.addSubviews()
        self.setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyMemoriesCollectionHeaderView {
    func setStatus(_ status: Status) {
        titleLabel.text = status.title
        
        if status == .member {
            showMemberCountLabel()
        } else {
            memberCountLabel.removeFromSuperview()
        }
    }
}

extension MyMemoriesCollectionHeaderView {
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(seeOtherMemoryMessageButton)
    }
    
    private func showMemberCountLabel() {
        addSubview(memberCountLabel)
        
        memberCountLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
        
        seeOtherMemoryMessageButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.height.equalTo(16)
        }
    }
}
