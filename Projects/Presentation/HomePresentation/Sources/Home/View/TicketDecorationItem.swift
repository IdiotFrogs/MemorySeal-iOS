//
//  TicketDecorationItem.swift
//  HomePresentation
//
//  Created by 선민재 on 9/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

struct TicketDecorationItem {
    let image: UIImage
    let size: CGSize
    let center: CGPoint
    let rotation: CGFloat
    let isMirroredX: Bool
    let isMirroredY: Bool

    init(
        image: UIImage,
        size: CGSize,
        center: CGPoint,
        rotation: CGFloat = 0,
        isMirroredX: Bool = false,
        isMirroredY: Bool = false
    ) {
        self.image = image
        self.size = size
        self.center = center
        self.rotation = rotation
        self.isMirroredX = isMirroredX
        self.isMirroredY = isMirroredY
    }

    func makeImageView() -> UIImageView {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }

    func apply(to imageView: UIImageView, scale: CGFloat) {
        imageView.transform = .identity
        imageView.bounds = CGRect(
            origin: .zero,
            size: CGSize(width: size.width * scale, height: size.height * scale)
        )
        imageView.center = CGPoint(x: center.x * scale, y: center.y * scale)
        imageView.transform = CGAffineTransform(
            scaleX: isMirroredX ? -1 : 1,
            y: isMirroredY ? -1 : 1
        )
        .concatenating(CGAffineTransform(rotationAngle: rotation * .pi / 180))
    }
}
