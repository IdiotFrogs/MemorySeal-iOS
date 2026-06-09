//
//  TicketUserCollectionViewCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 9/9/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

import DesignSystem
import TicketDomain

final class TicketUserCollectionViewCell: UICollectionViewCell {
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 24
        return imageView
    }()

    private let profileWavyBorder: WavyStrokeView = {
        let view = WavyStrokeView(strokeColor: .black, lineWidth: 2)
        view.waveCornerRadius = 24
        view.waveAmplitude = 1.0
        view.waveSpacing = 4
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.clipsToBounds = false
        contentView.clipsToBounds = false

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.kf.cancelDownloadTask()
        userImageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
    }

    func configure(collaborator: CollaboratorEntity) {
        let placeholder = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        guard let urlString = collaborator.profileImageUrl,
              let url = URL(string: urlString) else {
            userImageView.image = placeholder
            return
        }
        userImageView.kf.setImage(with: url, placeholder: placeholder)
    }
}

extension TicketUserCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(userImageView)
        contentView.addSubview(profileWavyBorder)
    }

    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        profileWavyBorder.snp.makeConstraints {
            $0.edges.equalTo(userImageView)
        }
    }
}
