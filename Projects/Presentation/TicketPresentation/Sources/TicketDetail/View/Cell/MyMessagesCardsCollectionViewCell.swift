//
//  MyMessagesCardsCollectionViewCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 5/12/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

final class MyMessagesCardsCollectionViewCell: UICollectionViewCell {
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.distribution = .fillEqually
        stack.alignment = .fill
        return stack
    }()

    private lazy var messageCard = makeCard(title: "메세지", status: "미등록")
    private lazy var photoCard = makeCard(title: "사진", status: "미등록")

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MyMessagesCardsCollectionViewCell {
    private func makeCard(title: String, status: String) -> UIView {
        let primaryLight = DesignSystemAsset.ColorAssests.primaryLight.color

        let container = WavyStrokeView(fillColor: primaryLight)
        container.waveCornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        titleLabel.textColor = DesignSystemAsset.ColorAssests.primaryDark.color

        let statusLabel = UILabel()
        statusLabel.text = status
        statusLabel.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        statusLabel.textColor = DesignSystemAsset.ColorAssests.primaryDark.color

        container.addSubview(titleLabel)
        container.addSubview(statusLabel)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        statusLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(16)
        }

        return container
    }

    private func addSubviews() {
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(messageCard)
        stackView.addArrangedSubview(photoCard)
    }

    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
