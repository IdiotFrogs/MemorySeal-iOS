//
//  MemoryUserCollectionViewCell.swift
//  MemoryPresentation
//
//  Created by 선민재 on 9/9/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class MemoryUserCollectionViewCell: UICollectionViewCell {
    private let userImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        return imageView
    }()

    private var hasRemoteImage: Bool = false
    private var wavyBorderLayer: WavyStrokeLayer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.clipsToBounds = false
        contentView.clipsToBounds = false

        self.addSubviews()
        self.setLayout()
        self.setupWavyBorderLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupWavyBorderLayer() {
        let newLayer = WavyStrokeLayer()
        newLayer.strokeColor = UIColor.black.cgColor
        newLayer.lineWidth = 2
        newLayer.waveCornerRadius = 24
        newLayer.waveAmplitude = 1.5
        newLayer.waveSpacing = 8
        newLayer.alignment = .outside
        newLayer.isHidden = true
        newLayer.frame = .zero
        self.layer.addSublayer(newLayer)
        wavyBorderLayer = newLayer
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let wavyBorderLayer else { return }
        let targetFrame = userImageView.frame
        guard targetFrame.size.width > 0, targetFrame.size.height > 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        if wavyBorderLayer.frame != targetFrame {
            wavyBorderLayer.frame = targetFrame
        }
        wavyBorderLayer.setNeedsPathRefresh()
        wavyBorderLayer.isHidden = !hasRemoteImage
        CATransaction.commit()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        userImageView.kf.cancelDownloadTask()
        userImageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        hasRemoteImage = false
        wavyBorderLayer?.isHidden = true
    }

    func configure(profileImageUrl: String?) {
        guard let urlString = profileImageUrl, let url = URL(string: urlString) else {
            userImageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
            hasRemoteImage = false
            wavyBorderLayer?.isHidden = true
            return
        }
        hasRemoteImage = true
        wavyBorderLayer?.isHidden = false
        userImageView.kf.setImage(
            with: url,
            placeholder: DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        )
    }
}

extension MemoryUserCollectionViewCell {
    private func addSubviews() {
        addSubview(userImageView)
    }

    private func setLayout() {
        userImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
