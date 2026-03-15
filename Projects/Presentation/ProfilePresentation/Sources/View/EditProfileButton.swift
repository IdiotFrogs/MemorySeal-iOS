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
    private let editIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.editIcon.image.withRenderingMode(
            .alwaysTemplate
        )
        imageView.tintColor = DesignSystemAsset.ColorAssests.grey3.color
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let titleTextLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필 수정"
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.isUserInteractionEnabled = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        layer.cornerRadius = 16
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension EditProfileButton {
    private func addSubviews() {
        addSubview(editIconImageView)
        addSubview(titleTextLabel)
    }

    private func setLayout() {
        editIconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(8)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(16)
        }

        titleTextLabel.snp.makeConstraints {
            $0.leading.equalTo(editIconImageView.snp.trailing).offset(2)
            $0.trailing.equalToSuperview().inset(10)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(8)
        }
    }
}
