import UIKit

import DesignSystem

final class WateringDayChipView: UIView {

    private enum Metric {
        static let outerRadiusRatio: CGFloat = 0.917
        static let innerRadiusRatio: CGFloat = 0.586
        static let photoRadiusRatio: CGFloat = 0.503
        static let lineWidthRatio: CGFloat = 0.0764
        static let xmarkRatio: CGFloat = 0.26
    }

    private var state: WateringDayChipState = .missed

    private let outerRingLayer: WavyStrokeLayer = {
        let layer = WavyStrokeLayer()
        layer.alignment = .outside
        return layer
    }()

    private let innerRingLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.clear.cgColor
        layer.lineCap = .round
        layer.lineJoin = .round
        return layer
    }()

    private let photoMaskLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.white.cgColor
        return layer
    }()

    let photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        imageView.isHidden = true
        return imageView
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        label.isHidden = true
        return label
    }()

    private let xmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.iconXmarkBlack16.image
            .withRenderingMode(.alwaysTemplate)
        imageView.tintColor = DesignSystemAsset.ColorAssests.grey3.color
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        layer.addSublayer(outerRingLayer)
        layer.addSublayer(innerRingLayer)
        addSubview(photoImageView)
        addSubview(titleLabel)
        addSubview(xmarkImageView)
        photoImageView.layer.mask = photoMaskLayer
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        updateGeometry()
    }

    func configure(with state: WateringDayChipState) {
        self.state = state

        switch state {
        case .watered:
            photoImageView.isHidden = false
            titleLabel.isHidden = true
            xmarkImageView.isHidden = true
            applyRingColor(DesignSystemAsset.ColorAssests.primaryNormal.color)
        case .today:
            photoImageView.isHidden = true
            titleLabel.isHidden = false
            xmarkImageView.isHidden = true
            titleLabel.text = "오늘"
            titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
            titleLabel.textColor = DesignSystemAsset.ColorAssests.grey5.color
            applyRingColor(DesignSystemAsset.ColorAssests.grey1.color)
        case .upcoming(let day):
            photoImageView.isHidden = true
            titleLabel.isHidden = false
            xmarkImageView.isHidden = true
            titleLabel.text = "\(day)"
            titleLabel.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
            titleLabel.textColor = DesignSystemAsset.ColorAssests.grey3.color
            applyRingColor(DesignSystemAsset.ColorAssests.grey1.color)
        case .missed:
            photoImageView.isHidden = true
            titleLabel.isHidden = true
            xmarkImageView.isHidden = false
            applyFillColor(DesignSystemAsset.ColorAssests.grey1.color)
        }

        setNeedsLayout()
    }
}

extension WateringDayChipView {
    private func applyRingColor(_ color: UIColor) {
        outerRingLayer.fillColor = UIColor.clear.cgColor
        outerRingLayer.strokeColor = color.cgColor
        innerRingLayer.strokeColor = color.cgColor
        innerRingLayer.isHidden = false
    }

    private func applyFillColor(_ color: UIColor) {
        outerRingLayer.fillColor = color.cgColor
        outerRingLayer.strokeColor = UIColor.clear.cgColor
        innerRingLayer.isHidden = true
    }

    private var isFilledState: Bool {
        if case .missed = state { return true }
        return false
    }

    private func updateGeometry() {
        let size = min(bounds.width, bounds.height)
        guard size > 0 else { return }

        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = size / 2
        let lineWidth = size * Metric.lineWidthRatio
        let ringInset = isFilledState ? 0 : radius * (1 - Metric.outerRadiusRatio)

        CATransaction.begin()
        CATransaction.setDisableActions(true)

        outerRingLayer.frame = bounds.insetBy(dx: ringInset, dy: ringInset)
        outerRingLayer.lineWidth = isFilledState ? 0 : lineWidth
        outerRingLayer.waveCornerRadius = outerRingLayer.bounds.width / 2
        outerRingLayer.setNeedsPathRefresh()

        if let basePath = outerRingLayer.path {
            var toView = CGAffineTransform(
                translationX: outerRingLayer.frame.minX,
                y: outerRingLayer.frame.minY
            )
            if let viewPath = basePath.copy(using: &toView) {
                innerRingLayer.frame = bounds
                innerRingLayer.lineWidth = lineWidth
                innerRingLayer.path = scaled(
                    viewPath,
                    by: Metric.innerRadiusRatio / Metric.outerRadiusRatio,
                    about: center
                )

                let photoSide = size * Metric.photoRadiusRatio * 2
                photoImageView.frame = CGRect(
                    x: center.x - photoSide / 2,
                    y: center.y - photoSide / 2,
                    width: photoSide,
                    height: photoSide
                )
                photoMaskLayer.frame = photoImageView.bounds
                let photoPath = scaled(
                    viewPath,
                    by: Metric.photoRadiusRatio / Metric.outerRadiusRatio,
                    about: center
                )
                var toPhoto = CGAffineTransform(
                    translationX: -photoImageView.frame.minX,
                    y: -photoImageView.frame.minY
                )
                photoMaskLayer.path = photoPath.copy(using: &toPhoto)
            }
        }

        let contentSide = size * Metric.photoRadiusRatio * 2
        titleLabel.frame = CGRect(
            x: center.x - contentSide / 2,
            y: center.y - contentSide / 2,
            width: contentSide,
            height: contentSide
        )

        let xmarkSide = size * Metric.xmarkRatio
        xmarkImageView.frame = CGRect(
            x: center.x - xmarkSide / 2,
            y: center.y - xmarkSide / 2,
            width: xmarkSide,
            height: xmarkSide
        )

        CATransaction.commit()
    }

    private func scaled(_ path: CGPath, by scale: CGFloat, about center: CGPoint) -> CGPath {
        var transform = CGAffineTransform(translationX: center.x, y: center.y)
            .scaledBy(x: scale, y: scale)
            .translatedBy(x: -center.x, y: -center.y)
        return path.copy(using: &transform) ?? path
    }
}
