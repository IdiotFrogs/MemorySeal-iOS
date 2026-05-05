//
//  WavyStrokeLayer.swift
//  DesignSystem
//
//  Created by 선민재 on 4/28/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

public final class WavyStrokeLayer: CAShapeLayer {

    // MARK: - Configurable

    public var waveAmplitude: CGFloat = 2.0 {
        didSet { regeneratePath() }
    }
    public var waveSpacing: CGFloat = 6.0 {
        didSet { regeneratePath() }
    }
    public var waveCornerRadius: CGFloat = 12.0 {
        didSet { regeneratePath() }
    }
    public var noiseSeed: UInt64 = 0xC0FFEE_BABE {
        didSet { regeneratePath() }
    }
    public var alignment: WavyStrokeAlignment = .outside {
        didSet { regeneratePath() }
    }

    // MARK: - Init

    public override init() {
        super.init()
        commonInit()
    }

    public override init(layer: Any) {
        super.init(layer: layer)
        if let other = layer as? WavyStrokeLayer {
            self.waveAmplitude = other.waveAmplitude
            self.waveSpacing = other.waveSpacing
            self.waveCornerRadius = other.waveCornerRadius
            self.noiseSeed = other.noiseSeed
            self.alignment = other.alignment
        }
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    private func commonInit() {
        fillColor = UIColor.clear.cgColor
        lineCap = .round
        lineJoin = .round
    }

    // MARK: - Public API

    public func setWavyStrokeColor(_ color: UIColor) {
        strokeColor = color.cgColor
    }

    // MARK: - Bounds tracking

    public override var bounds: CGRect {
        get { super.bounds }
        set {
            let oldSize = super.bounds.size
            super.bounds = newValue
            if newValue.size != oldSize {
                regeneratePath()
            }
        }
    }

    public override var frame: CGRect {
        get { super.frame }
        set {
            let oldSize = super.frame.size
            super.frame = newValue
            if newValue.size != oldSize {
                regeneratePath()
            }
        }
    }

    public func setNeedsPathRefresh() {
        regeneratePath()
    }

    // MARK: - Path

    private func regeneratePath() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        path = makeWavyPath().cgPath
        CATransaction.commit()
    }

    private func makeWavyPath() -> UIBezierPath {
        let amp = waveAmplitude
        let strokeBuffer = lineWidth / 2
        let baseInset = amp + strokeBuffer
        let signedInset: CGFloat = (alignment == .outside) ? 0 : baseInset
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

// MARK: - UIView attach helper

public extension UIView {
    @discardableResult
    func addWavyStrokeLayer(
        strokeColor: UIColor,
        lineWidth: CGFloat,
        cornerRadius: CGFloat = 12,
        alignment: WavyStrokeAlignment = .outside
    ) -> WavyStrokeLayer {
        let l = WavyStrokeLayer()
        l.strokeColor = strokeColor.cgColor
        l.lineWidth = lineWidth
        l.waveCornerRadius = cornerRadius
        l.alignment = alignment
        l.frame = bounds
        layer.addSublayer(l)
        return l
    }
}
