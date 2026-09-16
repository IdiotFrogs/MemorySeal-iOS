//
//  HomeBottomTabBarView.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

import DesignSystem

public final class HomeBottomTabBarView: UIView {

    private enum Layout {
        static let rowHeight: CGFloat = 80
        static let rowVerticalPadding: CGFloat = 12
        static let rowHorizontalPadding: CGFloat = 20
        static let rowSpacing: CGFloat = 12
        static let floatingButtonSize: CGFloat = 56
        static let pillHeight: CGFloat = 56
        static let pillBorderWidth: CGFloat = 3
        static let shadowOpacity: Float = 0.12
        static let shadowRadius: CGFloat = 1.95
        static let shadowOffset: CGSize = CGSize(width: 0, height: 4)
    }

    public let homeTabButton: UIButton
    public let openedTabButton: UIButton
    public let pillView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: .white,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.pillBorderWidth
        )
        view.clipsToBounds = false
        return view
    }()

    private let rowContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.clipsToBounds = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = Layout.shadowOpacity
        view.layer.shadowOffset = Layout.shadowOffset
        view.layer.shadowRadius = Layout.shadowRadius
        return view
    }()

    private let tabStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()

    private let itemButtons: [HomeBottomTabBarItemButton]

    public init() {
        let homeItemButton = HomeBottomTabBarItemButton(tab: .home)
        let openedItemButton = HomeBottomTabBarItemButton(tab: .opened)

        homeTabButton = homeItemButton
        openedTabButton = openedItemButton
        itemButtons = [homeItemButton, openedItemButton]

        super.init(frame: .zero)

        setInitialValues()
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()

        rowContainerView.layoutIfNeeded()

        pillView.waveCornerRadius = pillView.bounds.height / 2
        rowContainerView.layer.shadowPath = UIBezierPath(
            roundedRect: pillView.frame,
            cornerRadius: pillView.bounds.height / 2
        ).cgPath
    }

    public func select(index: Int) {
        itemButtons.enumerated().forEach { offset, button in
            button.isSelected = offset == index
        }
    }
}

// MARK: - Layout

extension HomeBottomTabBarView {
    private func setInitialValues() {
        backgroundColor = .clear
    }

    private func addSubviews() {
        addSubview(rowContainerView)
        rowContainerView.addSubview(pillView)
        pillView.addSubview(tabStackView)
        itemButtons.forEach { tabStackView.addArrangedSubview($0) }
    }

    private func setLayout() {
        rowContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(Layout.rowHeight)
        }

        pillView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(Layout.rowVerticalPadding)
            $0.leading.equalToSuperview().offset(Layout.rowHorizontalPadding)
            $0.trailing.equalToSuperview().inset(
                Layout.rowHorizontalPadding + Layout.floatingButtonSize + Layout.rowSpacing
            )
            $0.height.equalTo(Layout.pillHeight)
        }

        tabStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

// MARK: - Item Button

private final class HomeBottomTabBarItemButton: UIButton {

    private enum Layout {
        static let iconSize: CGFloat = 24
        static let contentSpacing: CGFloat = 2
        static let selectionBorderWidth: CGFloat = 2
    }

    override var isSelected: Bool {
        didSet {
            updateSelectionAppearance()
        }
    }

    private let selectionView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.grey5.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: Layout.selectionBorderWidth
        )
        view.isUserInteractionEnabled = false
        return view
    }()

    private let tabIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let tabTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    private let contentStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = Layout.contentSpacing
        stackView.isUserInteractionEnabled = false
        return stackView
    }()

    init(tab: HomeContainerTab) {
        super.init(frame: .zero)

        setInitialValues(with: tab)
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        selectionView.waveCornerRadius = selectionView.bounds.height / 2
    }
}

// MARK: - Layout

extension HomeBottomTabBarItemButton {
    private func setInitialValues(with tab: HomeContainerTab) {
        tabIconImageView.image = tab.icon
        tabTitleLabel.text = tab.title
        updateSelectionAppearance()
    }

    private func addSubviews() {
        addSubview(selectionView)
        addSubview(contentStackView)
        contentStackView.addArrangedSubview(tabIconImageView)
        contentStackView.addArrangedSubview(tabTitleLabel)
    }

    private func setLayout() {
        selectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        tabIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(Layout.iconSize)
        }

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    private func updateSelectionAppearance() {
        selectionView.isHidden = !isSelected
        tabIconImageView.tintColor = isSelected
            ? .white
            : DesignSystemAsset.ColorAssests.grey3.color
        tabTitleLabel.textColor = isSelected
            ? .white
            : DesignSystemAsset.ColorAssests.grey3.color
        tabTitleLabel.font = isSelected
            ? DesignSystemFontFamily.Pretendard.semiBold.font(size: 10)
            : DesignSystemFontFamily.Pretendard.medium.font(size: 10)
    }
}
