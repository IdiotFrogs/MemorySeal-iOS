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
        label.text = "첫 여행, 첫 추억"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
        return label
    }()

    private let ticketDateLabel: UILabel = {
        let label = UILabel()
        label.text = "2025. 02. 20. (목) ~ 오픈일"
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        label.numberOfLines = 0
        return label
    }()

    private let ticketDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "처음 함께 떠났던 여행의 순간들을 담은 우리의 작은 시간 저장소."
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.numberOfLines = 0
        return label
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
