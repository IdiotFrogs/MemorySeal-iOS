//
//  OpenedTicketCollectionViewCell.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/15/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher

import DesignSystem

final class OpenedTicketCollectionViewCell: UICollectionViewCell {
    private enum Layout {
        static let cornerRadius: CGFloat = 16
        static let strokeLineWidth: CGFloat = 4
        static let overlap: CGFloat = -7
        static let topHeightRatio: CGFloat = 0.42
        static let contentPadding: CGFloat = 12
    }

    private let topWavyView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()
    
    private let bottomWavyView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.strokeLineWidth
        )
        view.waveCornerRadius = Layout.cornerRadius
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.numberOfLines = 2
        label.lineBreakMode = .byCharWrapping
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 14)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color.withAlphaComponent(0.6)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, date: String) {
        titleLabel.text = title
        dateLabel.text = date
    }

    override func prepareForReuse() {
        super.prepareForReuse()
    }
}

extension OpenedTicketCollectionViewCell {
    private func addSubviews() {
        contentView.addSubview(topWavyView)

        contentView.addSubview(bottomWavyView)
        bottomWavyView.addSubview(titleLabel)
        bottomWavyView.addSubview(dateLabel)
    }

    private func setLayout() {
        topWavyView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(55)
        }

        bottomWavyView.snp.makeConstraints {
            $0.top.equalTo(topWavyView.snp.bottom).offset(Layout.overlap)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(Layout.contentPadding + 7)
            $0.leading.trailing.equalToSuperview().inset(Layout.contentPadding)
        }

        dateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(Layout.contentPadding)
            $0.bottom.lessThanOrEqualToSuperview().inset(Layout.contentPadding)
        }
    }
}
