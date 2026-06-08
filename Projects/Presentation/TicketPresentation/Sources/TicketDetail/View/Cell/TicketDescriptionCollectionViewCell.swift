//
//  TicketDescriptionCollectionViewCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 7/28/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

public final class TicketDescriptionCollectionViewCell: UICollectionViewCell {
    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
        return label
    }()

    private let ticketDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        label.numberOfLines = 0
        return label
    }()

    private let ticketDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.numberOfLines = 0
        return label
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd."
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white

        self.addSubViews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, description: String, createdAt: Date, openedAt: Date?) {
        ticketTitleLabel.text = title
        ticketDescriptionLabel.text = description
        let start = dateFormatter.string(from: createdAt)
        let end = openedAt.map { dateFormatter.string(from: $0) } ?? "오픈일"
        ticketDateLabel.text = "\(start) ~ \(end)"
    }
}

extension TicketDescriptionCollectionViewCell {
    private func addSubViews() {
        addSubview(ticketTitleLabel)
        addSubview(ticketDateLabel)
        addSubview(ticketDescriptionLabel)
    }

    private func setLayout() {
        ticketTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        ticketDateLabel.snp.makeConstraints {
            $0.top.equalTo(ticketTitleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        ticketDescriptionLabel.snp.makeConstraints {
            $0.top.equalTo(ticketDateLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
}
