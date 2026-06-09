//
//  DashedSeparatorView.swift
//  DesignSystem
//
//  Created by 선민재 on 6/9/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public final class DashedSeparatorView: UIView {

    public var strokeColor: UIColor {
        didSet { shapeLayer.strokeColor = strokeColor.cgColor }
    }

    public var lineWidth: CGFloat {
        didSet {
            shapeLayer.lineWidth = lineWidth
            updatePath()
        }
    }

    public var dashPattern: [NSNumber] {
        didSet { shapeLayer.lineDashPattern = dashPattern }
    }

    private let shapeLayer = CAShapeLayer()

    public init(
        strokeColor: UIColor = DesignSystemAsset.ColorAssests.grey1.color,
        lineWidth: CGFloat = 2,
        dashPattern: [NSNumber] = [8, 8]
    ) {
        self.strokeColor = strokeColor
        self.lineWidth = lineWidth
        self.dashPattern = dashPattern
        super.init(frame: .zero)
        backgroundColor = .clear
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = strokeColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.lineCap = .butt
        layer.addSublayer(shapeLayer)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updatePath()
    }

    private func updatePath() {
        guard bounds.width > 0 else { return }
        let y = bounds.midY
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: bounds.width, y: y))
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        shapeLayer.frame = bounds
        shapeLayer.path = path.cgPath
        CATransaction.commit()
    }
}
