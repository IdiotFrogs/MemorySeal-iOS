//
//  MemorySealCalendarCollectionViewCell.swift
//  DesignSystem
//
//  Created by 선민재 on 6/5/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

public final class MemorySealCalendarCollectionViewCell: UICollectionViewCell {
    private static let sealGreen = UIColor(
        red: 0x04 / 255.0,
        green: 0x8F / 255.0,
        blue: 0x27 / 255.0,
        alpha: 1.0
    )

    private let selectedWavyBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            lineWidth: 5
        )
        view.waveCornerRadius = 8
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textAlignment = .center
        return label
    }()

    private let sealLabel: UILabel = {
        let label = UILabel()
        label.text = "봉인일"
        label.font = DesignSystemFontFamily.Pretendard.semiBold.font(size: 11)
        label.textColor = MemorySealCalendarCollectionViewCell.sealGreen
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        stack.isUserInteractionEnabled = false
        return stack
    }()

    private var isInCurrentMonth: Bool = true
    private var isTodayDate: Bool = false

    public override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = false
        self.layer.cornerRadius = 8

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        super.prepareForReuse()

        self.selectedWavyBackground.isHidden = true
        self.sealLabel.isHidden = true
        self.isInCurrentMonth = true
        self.isTodayDate = false
        self.isUserInteractionEnabled = true
    }

    override public var isSelected: Bool {
        didSet {
            selectedWavyBackground.isHidden = !isSelected
            updateAppearance()
        }
    }

    public func configure(dateText: String, isCurrentMonth: Bool, isToday: Bool) {
        dateLabel.text = dateText
        self.isInCurrentMonth = isCurrentMonth
        self.isTodayDate = isToday
        self.isUserInteractionEnabled = isCurrentMonth
        updateAppearance()
    }
}

extension MemorySealCalendarCollectionViewCell {
    private func addSubviews() {
        addSubview(selectedWavyBackground)
        contentStackView.addArrangedSubview(dateLabel)
        contentStackView.addArrangedSubview(sealLabel)
        addSubview(contentStackView)
    }

    private func setLayout() {
        selectedWavyBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.lessThanOrEqualToSuperview()
        }
    }

    private func updateAppearance() {
        if isSelected {
            dateLabel.textColor = .white
            sealLabel.isHidden = true
        } else if isTodayDate {
            dateLabel.textColor = MemorySealCalendarCollectionViewCell.sealGreen
            sealLabel.isHidden = false
        } else if isInCurrentMonth == false {
            dateLabel.textColor = DesignSystemAsset.ColorAssests.grey2.color
            sealLabel.isHidden = true
        } else {
            dateLabel.textColor = DesignSystemAsset.ColorAssests.grey5.color
            sealLabel.isHidden = true
        }
    }
}
