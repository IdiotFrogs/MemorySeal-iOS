//
//  PhotoDetailTransitionSource.swift
//  TicketPresentation
//
//  Created by 선민재 on 10/19/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public final class PhotoDetailTransitionSource {

    private let provider: (Int) -> UIImageView?

    public init(provider: @escaping (Int) -> UIImageView?) {
        self.provider = provider
    }

    func imageView(at index: Int) -> UIImageView? {
        return provider(index)
    }
}

// MARK: - Aspect Fit

extension UIImageView {
    var aspectFitImageFrame: CGRect {
        guard let imageSize = image?.size,
              imageSize.width > 0,
              imageSize.height > 0,
              contentMode == .scaleAspectFit
        else {
            return bounds
        }

        let scale = min(bounds.width / imageSize.width, bounds.height / imageSize.height)
        let size = CGSize(width: imageSize.width * scale, height: imageSize.height * scale)

        return CGRect(
            x: bounds.midX - size.width / 2,
            y: bounds.midY - size.height / 2,
            width: size.width,
            height: size.height
        )
    }
}
