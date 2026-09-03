//
//  EditProfileButton.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

final class EditProfileButton: UIButton {
    private let titleTextLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 수정"
        label.textColor = .white
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        label.isUserInteractionEnabled = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignSystemAsset.ColorAssests.grey5.color
        layer.cornerRadius = 8
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditProfileButton {
    private func addSubviews() {
        addSubview(titleTextLabel)
    }

    private func setLayout() {
        titleTextLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
    }
}
