//
//  TutorialPageCell.swift
//  TutorialPresentation
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

final class TutorialPageCell: UICollectionViewCell {

    // MARK: - UI

    private let illustrationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let textContainerView: UIView = UIView()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.7
        return label
    }()

    private let bodyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 2
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.8
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .clear
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        illustrationImageView.image = nil
        titleLabel.attributedText = nil
        bodyLabel.attributedText = nil
    }

    // MARK: - Configure

    func configure(page: TutorialPage) {
        illustrationImageView.image = page.illustration
        titleLabel.attributedText = Self.attributedString(
            page.title,
            font: TutorialMetrics.titleFont,
            color: TutorialMetrics.titleColor,
            lineHeight: TutorialMetrics.titleLineHeight
        )
        bodyLabel.attributedText = Self.attributedString(
            page.body,
            font: TutorialMetrics.bodyFont,
            color: TutorialMetrics.bodyColor,
            lineHeight: TutorialMetrics.bodyLineHeight
        )
    }

    private static func attributedString(
        _ text: String,
        font: UIFont,
        color: UIColor,
        lineHeight: CGFloat
    ) -> NSAttributedString {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        paragraphStyle.minimumLineHeight = lineHeight
        paragraphStyle.maximumLineHeight = lineHeight

        return NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: color,
                .paragraphStyle: paragraphStyle,
                .baselineOffset: (lineHeight - font.lineHeight) / 4
            ]
        )
    }
}

// MARK: - Subviews

extension TutorialPageCell {
    private func addSubviews() {
        contentView.addSubview(illustrationImageView)
        contentView.addSubview(textContainerView)
        textContainerView.addSubview(titleLabel)
        textContainerView.addSubview(bodyLabel)
    }

    private func setLayout() {
        textContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(TutorialMetrics.horizontalInset)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(TutorialMetrics.textBlockHeight)
        }
        titleLabel.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        bodyLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(TutorialMetrics.titleToBodySpacing)
            $0.leading.trailing.bottom.equalToSuperview()
        }
        illustrationImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(TutorialMetrics.horizontalInset)
            $0.bottom.equalTo(textContainerView.snp.top)
                .offset(-TutorialMetrics.illustrationBottomSpacing)
        }
    }
}
