//
//  WaterTicketCollectionViewCell.swift
//  TicketPresentation
//
//  Created by 선민재 on 6/9/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class WaterTicketCollectionViewCell: UICollectionViewCell {
    var disposeBag = DisposeBag()

    private let dashedSeparator: DashedSeparatorView = {
        let view = DashedSeparatorView()
        return view
    }()

    let waterButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(
            DesignSystemAsset.ImageAssets.waterCardBackground.image,
            for: .normal
        )
        button.adjustsImageWhenHighlighted = false
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

extension WaterTicketCollectionViewCell {
    private func addSubviews() {
        addSubview(dashedSeparator)
        addSubview(waterButton)
    }

    private func setLayout() {
        dashedSeparator.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(2)
        }

        waterButton.snp.makeConstraints {
            $0.top.equalTo(dashedSeparator.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview()
            $0.height.equalTo(waterButton.snp.width).multipliedBy(289.0 / 1027.0)
        }
    }
}
