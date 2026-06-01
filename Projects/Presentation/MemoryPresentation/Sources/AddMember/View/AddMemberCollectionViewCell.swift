//
//  AddMemberCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 10/30/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

import DesignSystem

public enum AddMemberRole {
    case none
    case me
    case host
}

final class AddMemberCollectionViewCell: UICollectionViewCell {

    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()

    private let profileWavyBorder: WavyStrokeView = {
        let view = WavyStrokeView(strokeColor: .black, lineWidth: 2)
        view.waveCornerRadius = 20
        view.waveAmplitude = 1.0
        view.waveSpacing = 4
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.setContentHuggingPriority(.defaultLow, for: .horizontal)
        return label
    }()

    private let badgeContainerView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        view.isHidden = true
        return view
    }()

    private let badgeIconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.isHidden = true
        return iv
    }()

    private let badgeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()

    private let badgeStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        return stack
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

    func configure(
        name: String,
        profileImageUrl: String? = nil,
        role: AddMemberRole = .none
    ) {
        nameLabel.text = name

        if let urlString = profileImageUrl, let url = URL(string: urlString) {
            userImageView.kf.setImage(
                with: url,
                placeholder: DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
            )
        } else {
            userImageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        }

        switch role {
        case .none:
            badgeContainerView.isHidden = true
        case .me:
            badgeContainerView.isHidden = false
            badgeContainerView.backgroundColor = UIColor(hex: "#CFF2D8")
            badgeIconImageView.isHidden = true
            badgeLabel.text = "나"
            badgeLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
            badgeLabel.textColor = UIColor(hex: "#048F27")
        case .host:
            badgeContainerView.isHidden = false
            badgeContainerView.backgroundColor = UIColor(hex: "#F5F5F5")
            badgeIconImageView.isHidden = false
            badgeIconImageView.image = UIImage(systemName: "crown.fill")
            badgeIconImageView.tintColor = DesignSystemAsset.ColorAssests.grey4.color
            badgeLabel.text = "방장"
            badgeLabel.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 12)
            badgeLabel.textColor = DesignSystemAsset.ColorAssests.grey4.color
        }
    }
}

extension AddMemberCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(userImageView)
        contentView.addSubview(profileWavyBorder)
        contentView.addSubview(nameLabel)

        badgeStackView.addArrangedSubview(badgeIconImageView)
        badgeStackView.addArrangedSubview(badgeLabel)
        badgeContainerView.addSubview(badgeStackView)
        contentView.addSubview(badgeContainerView)
    }

    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        profileWavyBorder.snp.makeConstraints {
            $0.edges.equalTo(userImageView)
        }

        nameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(userImageView.snp.trailing).offset(16)
        }

        badgeContainerView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(nameLabel.snp.trailing).offset(8)
            $0.trailing.lessThanOrEqualToSuperview()
        }

        badgeStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(
                UIEdgeInsets(top: 4, left: 8, bottom: 4, right: 8)
            )
        }

        badgeIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(12)
        }
    }
}
