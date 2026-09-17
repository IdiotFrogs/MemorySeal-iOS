//
//  HomeSectionHeaderView.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SnapKit

import DesignSystem

final class HomeSectionHeaderView: UICollectionReusableView {

    static let elementKind: String = UICollectionView.elementKindSectionHeader
    static let identifier: String = String(describing: HomeSectionHeaderView.self)
    static let contentHeight: CGFloat = Layout.contentHeight

    private enum Layout {
        static let horizontalInset: CGFloat = 22.5
        static let titleFontSize: CGFloat = 20
        static let moreButtonSize: CGFloat = 20
        static let contentHeight: CGFloat = 24
    }

    private var onTapMore: (() -> Void)?

    // MARK: - Views

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: Layout.titleFontSize)
        label.numberOfLines = 1
        return label
    }()

    private let moreButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(
            DesignSystemAsset.ImageAssets.iconChevronRight24.image.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = DesignSystemAsset.ColorAssests.grey5.color
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        return button
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.setLayout()
        self.bindButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        moreButton.isHidden = true
        onTapMore = nil
    }
}

// MARK: - Configure

extension HomeSectionHeaderView {
    func configure(title: String, showsMore: Bool, onTapMore: (() -> Void)?) {
        titleLabel.text = title
        moreButton.isHidden = !showsMore
        self.onTapMore = onTapMore
    }

    private func bindButton() {
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }

    @objc
    private func didTapMoreButton() {
        onTapMore?()
    }
}

// MARK: - Layout

extension HomeSectionHeaderView {
    private func addSubviews() {
        addSubview(titleLabel)
        addSubview(moreButton)
    }

    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.horizontalInset)
            $0.top.equalToSuperview()
            $0.height.equalTo(Layout.contentHeight)
            $0.trailing.lessThanOrEqualTo(moreButton.snp.leading).offset(-Layout.horizontalInset)
        }

        moreButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.horizontalInset)
            $0.centerY.equalTo(titleLabel)
            $0.size.equalTo(Layout.moreButtonSize)
        }
    }
}
