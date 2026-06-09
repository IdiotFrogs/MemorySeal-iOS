//
//  BuryTicketCollectionViewCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 5/12/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class BuryTicketCollectionViewCell: UICollectionViewCell {
    var disposeBag = DisposeBag()

    private let dashedSeparator: DashedSeparatorView = {
        let view = DashedSeparatorView()
        return view
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "티켓 묻기"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        return label
    }()

    let buryButton: UIButton = {
        let button = UIButton()
        button.setTitle("티켓 묻기", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.backgroundColor = DesignSystemAsset.ColorAssests.grey5.color
        button.layer.cornerRadius = 8
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.disposeBag = DisposeBag()
    }
}

extension BuryTicketCollectionViewCell {
    private func addSubviews() {
        addSubview(dashedSeparator)
        addSubview(titleLabel)
        addSubview(buryButton)
    }

    private func setLayout() {
        dashedSeparator.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        }

        buryButton.snp.makeConstraints {
            $0.top.equalTo(dashedSeparator.snp.bottom).offset(28)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(76)
            $0.height.equalTo(32)
            $0.bottom.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(buryButton)
            $0.leading.equalToSuperview().offset(20)
        }
    }
}
