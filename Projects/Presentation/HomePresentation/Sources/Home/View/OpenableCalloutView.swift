//
//  OpenableCalloutView.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SnapKit

import DesignSystem

final class OpenableCalloutView: UIView {

    private enum Layout {
        static let borderWidth: CGFloat = 3
        static let contentInset: CGFloat = 12
        static let titleFontSize: CGFloat = 16
        static let waveAmplitude: CGFloat = 1.2
        static let waveSpacing: CGFloat = 4.5
    }

    private enum Text {
        static let title: String = "지금 열 수 있어요"
    }

    // MARK: - Views

    private let wavyBackgroundView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.borderWidth
        )
        view.waveAmplitude = Layout.waveAmplitude
        view.waveSpacing = Layout.waveSpacing
        view.strokeAlignment = .inside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = Text.title
        label.textColor = .black
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.titleFontSize)
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setInitialValues()
        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        wavyBackgroundView.waveCornerRadius = bounds.height / 2
    }
}

// MARK: - Layout

extension OpenableCalloutView {
    private func setInitialValues() {
        backgroundColor = .clear
        clipsToBounds = false
    }

    private func addSubviews() {
        addSubview(wavyBackgroundView)
        addSubview(titleLabel)
    }

    private func setLayout() {
        wavyBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.contentInset)
        }
    }
}
