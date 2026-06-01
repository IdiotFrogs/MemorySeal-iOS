//
//  DashedLineView.swift
//  DesignSystem
//
//  Created by 선민재 on 3/25/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public final class DashedLineView: UIView {
    private let shapeLayer = CAShapeLayer()

    public override init(frame: CGRect) {
        super.init(frame: frame)
        shapeLayer.strokeColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
        shapeLayer.lineWidth = 1
        shapeLayer.lineDashPattern = [4, 4]
        shapeLayer.fillColor = nil
        layer.addSublayer(shapeLayer)
    }

    public init(lineColor: UIColor, lineWidth: CGFloat, dashPattern: [NSNumber]) {
        super.init(frame: .zero)
        shapeLayer.strokeColor = lineColor.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineDashPattern = dashPattern
        shapeLayer.fillColor = nil
        shapeLayer.lineCap = .round
        layer.addSublayer(shapeLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        shapeLayer.frame = bounds
        let path = UIBezierPath()
        let y = bounds.midY
        path.move(to: CGPoint(x: 0, y: y))
        path.addLine(to: CGPoint(x: bounds.width, y: y))
        shapeLayer.path = path.cgPath
    }
}
