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
    }

    private enum Text {
        static let title: String = "지금 열 수 있어요"
    }

    // MARK: - Views

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

        layer.cornerRadius = bounds.height / 2
    }
}

// MARK: - Layout

extension OpenableCalloutView {
    private func setInitialValues() {
        backgroundColor = .white
        layer.borderWidth = Layout.borderWidth
        layer.borderColor = DesignSystemAsset.ColorAssests.grey5.color.cgColor
        layer.cornerCurve = .continuous
        clipsToBounds = true
    }

    private func addSubviews() {
        addSubview(titleLabel)
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(Layout.contentInset)
        }
    }
}
