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

    private let pillContainer: UIView = UIView()

    private let pill: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        view.layer.cornerRadius = 12
        view.clipsToBounds = true
        return view
    }()

    private let pillIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.shovelFill16.image
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let pillLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 12)
        label.textColor = UIColor(hex: "#454545") ?? .darkGray
        return label
    }()

    private let ticketTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
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

    private let ticketDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey3.color
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 14)
        label.numberOfLines = 0
        return label
    }()

    private let outerStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .leading
        stack.spacing = 24
        return stack
    }()

    private let detailStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .fill
        stack.spacing = 12
        return stack
    }()

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd. (E)"
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

    func configure(
        title: String,
        description: String,
        createdAt: Date,
        openedAt: Date?,
        isBuried: Bool
    ) {
        ticketTitleLabel.text = title
        ticketDescriptionLabel.text = description
        let start = dateFormatter.string(from: createdAt)
        let end = openedAt.map { dateFormatter.string(from: $0) } ?? "오픈일"
        ticketDateLabel.text = "\(start) ~ \(end)"

        if isBuried, let openedAt {
            let daysRemaining = max(
                0,
                Calendar.current.dateComponents([.day], from: Date(), to: openedAt).day ?? 0
            )
            pillLabel.text = "오픈까지 \(daysRemaining)일 남음"
            pillContainer.isHidden = false
        } else {
            pillContainer.isHidden = true
        }
    }
}

extension TicketDescriptionCollectionViewCell {
    private func addSubViews() {
        contentView.addSubview(outerStack)
        outerStack.addArrangedSubview(pillContainer)
        outerStack.addArrangedSubview(detailStack)

        pillContainer.addSubview(pill)
        pill.addSubview(pillIcon)
        pill.addSubview(pillLabel)

        detailStack.addArrangedSubview(ticketTitleLabel)
        detailStack.addArrangedSubview(ticketDescriptionLabel)
        detailStack.addArrangedSubview(ticketDateLabel)
    }

    private func setLayout() {
        outerStack.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
        }

        pill.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        pillIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(10)
            $0.centerY.equalToSuperview()
            $0.top.bottom.equalToSuperview().inset(8)
            $0.width.height.equalTo(16)
        }

        pillLabel.snp.makeConstraints {
            $0.leading.equalTo(pillIcon.snp.trailing).offset(4)
            $0.trailing.equalToSuperview().inset(12)
            $0.centerY.equalToSuperview()
        }
    }
}
