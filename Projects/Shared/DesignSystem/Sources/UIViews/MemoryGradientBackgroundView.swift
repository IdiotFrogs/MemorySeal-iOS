//
//  MemoryGradientBackgroundView.swift
//  DesignSystem
//
//  Created by 선민재 on 8/4/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public final class MemoryGradientBackgroundView: UIView {

    // MARK: - Constant

    private enum Metric {
        static let designWidth: CGFloat = 375
        static let designHeight: CGFloat = 812
        static let blurRadius: CGFloat = 80
        static let marginMultiplier: CGFloat = 3
    }

    private struct Blob {
        let color: UIColor
        let center: CGPoint
        let radius: CGFloat
    }

    private static let blobs: [Blob] = [
        Blob(
            color: UIColor(red: 244 / 255, green: 244 / 255, blue: 204 / 255, alpha: 1),
            center: CGPoint(x: 199.5, y: 418.5),
            radius: 431.5
        ),
        Blob(
            color: UIColor(red: 224 / 255, green: 196 / 255, blue: 9 / 255, alpha: 1),
            center: CGPoint(x: 320, y: 135),
            radius: 116
        ),
        Blob(
            color: UIColor(red: 52 / 255, green: 199 / 255, blue: 89 / 255, alpha: 1),
            center: CGPoint(x: 117, y: 358),
            radius: 213
        ),
        Blob(
            color: UIColor(red: 64 / 255, green: 216 / 255, blue: 191 / 255, alpha: 1),
            center: CGPoint(x: 361, y: 523),
            radius: 145
        )
    ]

    // MARK: - Properties

    private var renderedSize: CGSize = .zero
    private static var imageCache: [String: UIImage] = [:]

    // MARK: - Init

    public init() {
        super.init(frame: .zero)

        backgroundColor = .white
        isUserInteractionEnabled = false
        layer.contentsGravity = .resize
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()

        guard bounds.width > 0, bounds.height > 0, bounds.size != renderedSize else { return }

        renderedSize = bounds.size
        layer.contents = cachedGradientImage(size: bounds.size)?.cgImage
    }

    // MARK: - Rendering

    private func cachedGradientImage(size: CGSize) -> UIImage? {
        let key = "\(Int(size.width.rounded()))x\(Int(size.height.rounded()))"
        if let cached = Self.imageCache[key] { return cached }

        guard let image = makeGradientImage(size: size) else { return nil }
        Self.imageCache[key] = image
        return image
    }

    private func makeGradientImage(size: CGSize) -> UIImage? {
        let scale = max(size.width / Metric.designWidth, size.height / Metric.designHeight)
        let blurRadius = Metric.blurRadius * scale
        let margin = blurRadius * Metric.marginMultiplier
        let canvasSize = CGSize(width: size.width + margin * 2, height: size.height + margin * 2)

        let format = UIGraphicsImageRendererFormat.default()
        format.scale = 1
        format.opaque = true

        let canvas = UIGraphicsImageRenderer(size: canvasSize, format: format).image { context in
            UIColor.white.setFill()
            context.fill(CGRect(origin: .zero, size: canvasSize))

            Self.blobs.forEach { blob in
                let radius = blob.radius * scale
                let rect = CGRect(
                    x: blob.center.x * scale + margin - radius,
                    y: blob.center.y * scale + margin - radius,
                    width: radius * 2,
                    height: radius * 2
                )
                blob.color.setFill()
                context.cgContext.fillEllipse(in: rect)
            }
        }

        guard let inputImage = CIImage(image: canvas),
              let filter = CIFilter(name: "CIGaussianBlur") else { return canvas }

        filter.setValue(inputImage.clampedToExtent(), forKey: kCIInputImageKey)
        filter.setValue(blurRadius, forKey: kCIInputRadiusKey)

        let cropRect = CGRect(x: margin, y: margin, width: size.width, height: size.height)

        guard let output = filter.outputImage,
              let cgImage = CIContext().createCGImage(output, from: cropRect) else { return canvas }

        return UIImage(cgImage: cgImage)
    }
}
