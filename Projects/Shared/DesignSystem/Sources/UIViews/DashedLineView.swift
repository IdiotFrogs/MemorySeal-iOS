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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: bounds.width, y: 0))
        shapeLayer.path = path.cgPath
    }
}
