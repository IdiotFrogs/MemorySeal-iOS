//
//  TicketImageCollectionViewCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class TicketImageCollectionViewCell: UICollectionViewCell {
    private let ticketImageView: UIImageView = {
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

    private let bottomWavyMask: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: .black,
            lineWidth: 5
        )
        view.waveCornerRadius = 0
        view.waveAmplitude = 3
        view.waveSpacing = 6
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        contentView.clipsToBounds = true

        self.addSubViews()
        self.setLayout()
        ticketImageView.layer.addSublayer(gradientLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        gradientLayer.frame = ticketImageView.bounds
        CATransaction.commit()
    }

    func configure(imageUrl: String?) {
        let placeholder = DesignSystemAsset.ImageAssets.ticketDummyImage.image
        guard let imageUrl, let url = URL(string: imageUrl) else {
            ticketImageView.image = placeholder
            return
        }
        ticketImageView.kf.setImage(
            with: url,
            placeholder: placeholder,
            options: [.transition(.fade(0.2))]
        )
    }
}

extension TicketImageCollectionViewCell {
    private func addSubViews() {
        addSubview(ticketImageView)
        addSubview(bottomWavyMask)
    }

    private func setLayout() {
        ticketImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bottomWavyMask.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(-40)
            $0.trailing.equalToSuperview().offset(40)
            $0.bottom.equalToSuperview().offset(20)
            $0.height.equalTo(25)
        }
    }
}
