//
//  WavyPhotoView.swift
//  HomePresentation
//
//  Created by 선민재 on 6/22/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import DesignSystem

final class WavyPhotoView: UIView {

    private enum Asset {
        static let cornerRadius: CGFloat = 12
        static let canvasWidth: CGFloat = 315
        static let canvasHeight: CGFloat = 317
        static let innerX: CGFloat = 16.83
        static let innerY: CGFloat = 18.04
        static let innerWidth: CGFloat = 281.1
        static let innerHeight: CGFloat = 280.27
    }

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = Asset.cornerRadius
        imageView.layer.cornerCurve = .continuous
        return imageView
    }()

    private let frameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.ticketWavyFrame.image
        imageView.contentMode = .scaleToFill
        return imageView
    }()

    var image: UIImage? {
        get { imageView.image }
        set { imageView.image = newValue }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = false
        addSubview(imageView)
        addSubview(frameImageView)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        guard bounds.width > 0, bounds.height > 0 else { return }

        let scaleX = bounds.width / Asset.innerWidth
        let scaleY = bounds.height / Asset.innerHeight
        frameImageView.frame = CGRect(
            x: -Asset.innerX * scaleX,
            y: -Asset.innerY * scaleY,
            width: Asset.canvasWidth * scaleX,
            height: Asset.canvasHeight * scaleY
        )
    }
}
