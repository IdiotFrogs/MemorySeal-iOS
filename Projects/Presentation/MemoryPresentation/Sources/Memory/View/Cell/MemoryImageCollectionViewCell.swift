//
//  MemoryImageCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class MemoryImageCollectionViewCell: UICollectionViewCell {
    private let memoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()

    private let gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.colors = [
            UIColor.black.withAlphaComponent(0.2).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0).cgColor,
            UIColor.black.withAlphaComponent(0.2).cgColor
        ]
        layer.locations = [0.0, 0.24, 0.697, 1.0]
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubViews()
        self.setLayout()
        memoryImageView.layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = memoryImageView.bounds
        CATransaction.commit()
    }

    func configure(imageUrl: String?) {
        guard let urlString = imageUrl, let url = URL(string: urlString) else {
            memoryImageView.image = nil
            return
        }
        memoryImageView.kf.setImage(with: url)
    }
}

extension MemoryImageCollectionViewCell {
    private func addSubViews() {
        addSubview(memoryImageView)
    }

    private func setLayout() {
        memoryImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
