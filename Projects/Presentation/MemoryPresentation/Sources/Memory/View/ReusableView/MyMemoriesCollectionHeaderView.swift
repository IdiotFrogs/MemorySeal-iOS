//
//  MyMemoriesCollectionHeaderView.swift
//  MemoryPresentation
//
//  Created by 선민재 on 8/19/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class MyMemoriesCollectionHeaderView: UICollectionReusableView {
    enum Status {
        case message
        case member

        var title: String {
            switch self {
            case .member:
                return "맴버"
            case .message:
                return "나의 추억 메시지"
            }
        }
    }

    var disposeBag = DisposeBag()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        return label
    }()

    private let memberCountLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        return label
    }()

    private let seeOtherButton: UIButton = {
        let button = UIButton()
        button.setImage(DesignSystemAsset.ImageAssets.rightArrowImage.image, for: .normal)
        return button
    }()

    var didTapSeeOtherButton: ControlEvent<Void> {
        return seeOtherButton.rx.tap
    }

    public override init(frame: CGRect) {
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
        memberCountLabel.removeFromSuperview()
    }
}

extension MyMemoriesCollectionHeaderView {
    func setStatus(_ status: Status, memberCount: Int? = nil) {
        titleLabel.text = status.title
        memberCountLabel.removeFromSuperview()

        if status == .member {
            memberCountLabel.text = memberCount.map(String.init) ?? "0"
            showMemberCountLabel()
        }
    }
}

extension MyMemoriesCollectionHeaderView {
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(seeOtherButton)
    }

    private func showMemberCountLabel() {
        addSubview(memberCountLabel)

        memberCountLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.leading.equalTo(titleLabel.snp.trailing).offset(4)
        }
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
        }

        seeOtherButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.width.height.equalTo(16)
        }
    }
}
