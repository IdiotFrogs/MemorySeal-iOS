//
//  MemoryUserCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 9/9/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

final class TicketUserCollectionViewCell: UICollectionViewCell {
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = false
        return imageView
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
}

extension TicketUserCollectionViewCell {
    private func addSubviews() {
        addSubview(userImageView)
    }

    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
