//
//  UIImage.swift
//  DesignSystem
//
//  Created by 선민재 on 9/29/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public extension UIImage {
    func squareCropped(maxDimension: CGFloat) -> UIImage {
        let shortSide = min(size.width, size.height)
        guard shortSide > 0 else { return self }

        let targetSide = min(shortSide, maxDimension)
        let scale = targetSide / shortSide
        let scaledSize = CGSize(width: size.width * scale, height: size.height * scale)
        let origin = CGPoint(
            x: (targetSide - scaledSize.width) / 2,
            y: (targetSide - scaledSize.height) / 2
        )

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1

        let renderer = UIGraphicsImageRenderer(
            size: CGSize(width: targetSide, height: targetSide),
            format: format
        )

        return renderer.image { _ in
            draw(in: CGRect(origin: origin, size: scaledSize))
        }
    }
}
