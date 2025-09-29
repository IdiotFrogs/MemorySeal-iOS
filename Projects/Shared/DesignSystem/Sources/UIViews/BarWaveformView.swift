//
//  BarWaveformView.swift
//  DesignSystem
//
//  Created by 선민재 on 8/20/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import AVFoundation

public final class BarWaveformView: UIView {
    var amplitudes: [CGFloat] = [] {
        didSet { setNeedsDisplay() }
    }

    public override func draw(_ rect: CGRect) {
        guard !amplitudes.isEmpty else { return }
        guard let ctx = UIGraphicsGetCurrentContext() else { return }

        let midY = rect.midY
        let barWidth: CGFloat = rect.width / CGFloat(amplitudes.count)
        let maxHeight: CGFloat = rect.height / 2

        ctx.setFillColor(UIColor.black.cgColor)

        for (i, amp) in amplitudes.enumerated() {
            let barHeight = amp * maxHeight
            let x = CGFloat(i) * barWidth
            let y = midY - barHeight

            let barRect = CGRect(x: x,
                                 y: y,
                                 width: barWidth * 0.6, // 약간 좁게
                                 height: barHeight * 2)
            ctx.fill(barRect)
        }
    }
    
    public func loadAudio(url: URL) {
        guard let audioFile = try? AVAudioFile(forReading: url) else { return }
        
        let format = audioFile.processingFormat
        let frameCount = UInt32(audioFile.length)
        
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return }
        try? audioFile.read(into: buffer)

        guard let channelData = buffer.floatChannelData?[0] else { return }
        
        let data = Array(UnsafeBufferPointer(
            start: channelData,
            count: Int(buffer.frameLength)
        ))

        // 샘플링 (뷰의 너비 기준)
        let sampleCount = Int(bounds.width / 3) // 대략 4px 간격
        let strideValue = max(1, data.count / sampleCount)

        var samples: [CGFloat] = stride(
            from: 0,
            to: data.count,
            by: strideValue
        ).map {
            abs(CGFloat(data[$0]))
        }

        // 정규화 (0~1 사이로)
        if let maxAmp = samples.max(), maxAmp > 0 {
            samples = samples.map { $0 / maxAmp }
        }

        self.amplitudes = samples
    }
}
