//
//  WavyStrokeView.swift
//  DesignSystem
//
//  Created by 선민재 on 4/23/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public enum WavyStrokeStyle {
    case filled(color: UIColor)
    case stroked(color: UIColor, lineWidth: CGFloat)
    case filledStroked(fill: UIColor, stroke: UIColor, lineWidth: CGFloat)
}

public enum WavyStrokeAlignment {
    case inside
    case outside
}

public final class WavyStrokeView: UIView {

    // MARK: - Properties

    public var style: WavyStrokeStyle {
        didSet { applyStyle() }
    }

    public var waveAmplitude: CGFloat = 2.0 {
        didSet { updateAppearance() }
    }

    public var waveSpacing: CGFloat = 6.0 {
        didSet { updateAppearance() }
    }

    public var waveCornerRadius: CGFloat = 16.0 {
        didSet { updateAppearance() }
    }

    public var noiseSeed: UInt64 = 0xC0FFEE_BABE {
        didSet { updateAppearance() }
    }

    public var strokeAlignment: WavyStrokeAlignment = .inside {
        didSet { updateAppearance() }
    }

    public func setStrokeColor(_ color: UIColor) {
        switch style {
        case .stroked(_, let lineWidth):
            style = .stroked(color: color, lineWidth: lineWidth)
        case .filledStroked(let fill, _, let lineWidth):
            style = .filledStroked(fill: fill, stroke: color, lineWidth: lineWidth)
        case .filled:
            break
        }
    }

    private let maskLayer = CAShapeLayer()
    private let fillLayer = CAShapeLayer()
    private let strokeLayer = CAShapeLayer()

    // MARK: - Init

    public init(style: WavyStrokeStyle) {
        self.style = style
        super.init(frame: .zero)
        layer.insertSublayer(fillLayer, at: 0)
        layer.addSublayer(strokeLayer)
        applyStyle()
    }

    public convenience init(fillColor: UIColor = DesignSystemAsset.ColorAssests.primaryLight.color) {
        self.init(style: .filled(color: fillColor))
    }

    public convenience init(strokeColor: UIColor, lineWidth: CGFloat = 1.5) {
        self.init(style: .stroked(color: strokeColor, lineWidth: lineWidth))
    }

    public convenience init(
        fillColor: UIColor,
        strokeColor: UIColor,
        lineWidth: CGFloat
    ) {
        self.init(style: .filledStroked(fill: fillColor, stroke: strokeColor, lineWidth: lineWidth))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Style

    private func applyStyle() {
        switch style {
        case .filled(let color):
            backgroundColor = color
            layer.mask = maskLayer
            fillLayer.isHidden = true
            strokeLayer.isHidden = true
        case .stroked(let color, let lineWidth):
            backgroundColor = .clear
            layer.mask = nil
            fillLayer.isHidden = true
            strokeLayer.isHidden = false
            strokeLayer.fillColor = UIColor.clear.cgColor
            strokeLayer.strokeColor = color.cgColor
            strokeLayer.lineWidth = lineWidth
            strokeLayer.lineJoin = .round
            strokeLayer.lineCap = .round
        case .filledStroked(let fill, let stroke, let lineWidth):
            backgroundColor = .clear
            layer.mask = nil
            fillLayer.isHidden = false
            fillLayer.fillColor = fill.cgColor
            fillLayer.strokeColor = UIColor.clear.cgColor
            strokeLayer.isHidden = false
            strokeLayer.fillColor = UIColor.clear.cgColor
            strokeLayer.strokeColor = stroke.cgColor
            strokeLayer.lineWidth = lineWidth
            strokeLayer.lineJoin = .round
            strokeLayer.lineCap = .round
        }
        updateAppearance()
    }

    // MARK: - Layout

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearance()
    }

    public override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        if !strokeLayer.isHidden {
            layer.addSublayer(strokeLayer)
        }
    }

    private func updateAppearance() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        let path = makeWavyPath().cgPath
        maskLayer.frame = bounds
        maskLayer.path = path
        fillLayer.frame = bounds
        fillLayer.path = path
        strokeLayer.frame = bounds
        strokeLayer.path = path
    }

    // MARK: - Wavy Path

    private func makeWavyPath() -> UIBezierPath {
        let amp = waveAmplitude
        let strokeBuffer: CGFloat = {
            switch style {
            case .stroked(_, let lineWidth), .filledStroked(_, _, let lineWidth):
                return lineWidth / 2
            case .filled:
                return 0
            }
        }()
        let baseInset = amp + strokeBuffer
        let signedInset: CGFloat = {
            switch (style, strokeAlignment) {
            case (.stroked, .outside), (.filledStroked, .outside):
                return 0
            default:
                return baseInset
            }
        }()
        let inset = bounds.insetBy(dx: signedInset, dy: signedInset)
        let radius = max(0, min(
            waveCornerRadius - signedInset,
            min(inset.width, inset.height) / 2
        ))

        let samples = perimeterSamples(
            rect: inset,
            cornerRadius: radius,
            spacing: max(waveSpacing, 1)
        )

        guard samples.count >= 3 else {
            return UIBezierPath(roundedRect: inset, cornerRadius: radius)
        }

        let perturbed = perturb(samples: samples, amplitude: amp)
        return smoothPath(through: perturbed)
    }

    // MARK: - Perimeter Sampling

    private struct PerimeterSample {
        let point: CGPoint
        let normal: CGVector
    }

    private func perimeterSamples(
        rect: CGRect,
        cornerRadius r: CGFloat,
        spacing: CGFloat
    ) -> [PerimeterSample] {
        var result: [PerimeterSample] = []

        appendLine(
            from: CGPoint(x: rect.minX + r, y: rect.minY),
            to: CGPoint(x: rect.maxX - r, y: rect.minY),
            normal: CGVector(dx: 0, dy: -1),
            spacing: spacing,
            into: &result
        )
        appendArc(
            center: CGPoint(x: rect.maxX - r, y: rect.minY + r),
            radius: r,
            startAngle: -.pi / 2,
            endAngle: 0,
            spacing: spacing,
            into: &result
        )
        appendLine(
            from: CGPoint(x: rect.maxX, y: rect.minY + r),
            to: CGPoint(x: rect.maxX, y: rect.maxY - r),
            normal: CGVector(dx: 1, dy: 0),
            spacing: spacing,
            into: &result
        )
        appendArc(
            center: CGPoint(x: rect.maxX - r, y: rect.maxY - r),
            radius: r,
            startAngle: 0,
            endAngle: .pi / 2,
            spacing: spacing,
            into: &result
        )
        appendLine(
            from: CGPoint(x: rect.maxX - r, y: rect.maxY),
            to: CGPoint(x: rect.minX + r, y: rect.maxY),
            normal: CGVector(dx: 0, dy: 1),
            spacing: spacing,
            into: &result
        )
        appendArc(
            center: CGPoint(x: rect.minX + r, y: rect.maxY - r),
            radius: r,
            startAngle: .pi / 2,
            endAngle: .pi,
            spacing: spacing,
            into: &result
        )
        appendLine(
            from: CGPoint(x: rect.minX, y: rect.maxY - r),
            to: CGPoint(x: rect.minX, y: rect.minY + r),
            normal: CGVector(dx: -1, dy: 0),
            spacing: spacing,
            into: &result
        )
        appendArc(
            center: CGPoint(x: rect.minX + r, y: rect.minY + r),
            radius: r,
            startAngle: .pi,
            endAngle: 3 * .pi / 2,
            spacing: spacing,
            into: &result
        )

        return result
    }

    private func appendLine(
        from start: CGPoint,
        to end: CGPoint,
        normal: CGVector,
        spacing: CGFloat,
        into samples: inout [PerimeterSample]
    ) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let length = hypot(dx, dy)
        guard length > 0 else { return }

        let count = max(1, Int(length / spacing))
        for i in 0..<count {
            let t = CGFloat(i) / CGFloat(count)
            let point = CGPoint(x: start.x + dx * t, y: start.y + dy * t)
            samples.append(PerimeterSample(point: point, normal: normal))
        }
    }

    private func appendArc(
        center: CGPoint,
        radius: CGFloat,
        startAngle: CGFloat,
        endAngle: CGFloat,
        spacing: CGFloat,
        into samples: inout [PerimeterSample]
    ) {
        let arcLength = abs(endAngle - startAngle) * radius
        let count = max(1, Int(arcLength / spacing))
        for i in 0..<count {
            let t = CGFloat(i) / CGFloat(count)
            let angle = startAngle + (endAngle - startAngle) * t
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )
            samples.append(PerimeterSample(
                point: point,
                normal: CGVector(dx: cos(angle), dy: sin(angle))
            ))
        }
    }

    // MARK: - Perturbation & Smoothing

    private func perturb(samples: [PerimeterSample], amplitude: CGFloat) -> [CGPoint] {
        var seed = noiseSeed
            &+ UInt64(bitPattern: Int64(bounds.width.rounded()))
            &+ (UInt64(bitPattern: Int64(bounds.height.rounded())) &* 1_000_003)

        return samples.map { sample in
            seed = seed &* 6364136223846793005 &+ 1442695040888963407
            let rand = CGFloat(seed % 2000) / 1000.0 - 1.0
            let offset = rand * amplitude
            return CGPoint(
                x: sample.point.x + sample.normal.dx * offset,
                y: sample.point.y + sample.normal.dy * offset
            )
        }
    }

    private func smoothPath(through points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        let count = points.count
        let startMid = midpoint(points[count - 1], points[0])
        path.move(to: startMid)
        for i in 0..<count {
            let current = points[i]
            let next = points[(i + 1) % count]
            path.addQuadCurve(to: midpoint(current, next), controlPoint: current)
        }
        path.close()
        return path
    }

    private func midpoint(_ a: CGPoint, _ b: CGPoint) -> CGPoint {
        CGPoint(x: (a.x + b.x) / 2, y: (a.y + b.y) / 2)
    }
}
