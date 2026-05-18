//
//  MyMessagesCardsCollectionViewCell.swift
//  MemoryPresentation
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

    private let messageStatusLabel: UILabel = MyMessagesCardsCollectionViewCell.makeStatusLabel()
    private let photoStatusLabel: UILabel = MyMessagesCardsCollectionViewCell.makeStatusLabel()

    private lazy var messageCard = makeCard(title: "메세지", statusLabel: messageStatusLabel)
    private lazy var photoCard = makeCard(title: "사진", statusLabel: photoStatusLabel)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white

        self.addSubviews()
        self.setLayout()
        self.configure(contentCount: 0, imageCount: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(contentCount: Int, imageCount: Int) {
        messageStatusLabel.text = Self.statusText(count: contentCount)
        photoStatusLabel.text = Self.statusText(count: imageCount)
    }

    private static func statusText(count: Int) -> String {
        return count == 0 ? "미등록" : "\(count)개 등록"
    }

    private static func makeStatusLabel() -> UILabel {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 12)
        label.textColor = DesignSystemAsset.ColorAssests.primaryDark.color
        return label
    }
}

extension MyMessagesCardsCollectionViewCell {
    private func makeCard(title: String, statusLabel: UILabel) -> UIView {
        let primaryLight = DesignSystemAsset.ColorAssests.primaryLight.color

        let container = WavyStrokeView(fillColor: primaryLight)
        container.waveCornerRadius = 12

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        titleLabel.textColor = DesignSystemAsset.ColorAssests.primaryDark.color

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
