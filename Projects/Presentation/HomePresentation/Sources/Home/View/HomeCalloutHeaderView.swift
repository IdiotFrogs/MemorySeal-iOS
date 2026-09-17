//
//  HomeCalloutHeaderView.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SnapKit

import DesignSystem

final class HomeCalloutHeaderView: UICollectionReusableView {

    static let elementKind: String = UICollectionView.elementKindSectionHeader
    static let identifier: String = String(describing: HomeCalloutHeaderView.self)
    static let height: CGFloat = Layout.topInset + Layout.calloutHeight + Layout.bottomInset

    private enum Layout {
        static let topInset: CGFloat = 12
        static let calloutHeight: CGFloat = 43
        static let bottomInset: CGFloat = 25
    }

    private enum Decoration {
        static let designWidth: CGFloat = 132

        static let items: [TicketDecorationItem] = [
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroCalloutLeaf01.image,
            size: CGSize(width: 21.807, height: 11.068),
            center: CGPoint(x: -3.48, y: 30.28),
            rotation: -167.24,
            isMirroredX: false,
            isMirroredY: true
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroCalloutLeaf01.image,
            size: CGSize(width: 21.807, height: 11.068),
            center: CGPoint(x: 137.06, y: 26.25),
            rotation: -7.36,
            isMirroredX: false,
            isMirroredY: false
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroCalloutLeaf01.image,
            size: CGSize(width: 21.807, height: 11.068),
            center: CGPoint(x: -3.48, y: 37.23),
            rotation: 166.29,
            isMirroredX: false,
            isMirroredY: true
        ),
        TicketDecorationItem(
            image: DesignSystemAsset.ImageAssets.heroCalloutFlower01.image,
            size: CGSize(width: 23.868, height: 24.009),
            center: CGPoint(x: 126.67, y: 35.7),
            rotation: 31.34,
            isMirroredX: false,
            isMirroredY: false
        )
        ]
    }

    // MARK: - Views

    private lazy var decorationImageViews: [UIImageView] = Decoration.items.map { $0.makeImageView() }

    private let calloutView: OpenableCalloutView = {
        let view = OpenableCalloutView(frame: .zero)
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.clipsToBounds = false
        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        applyDecorations()
    }
}

// MARK: - Layout

extension HomeCalloutHeaderView {
    private func addSubviews() {
        addSubview(calloutView)
        decorationImageViews.forEach { addSubview($0) }
    }

    private func applyDecorations() {
        let calloutFrame = calloutView.frame
        let scale = calloutFrame.width / Decoration.designWidth
        guard scale > 0 else { return }

        zip(decorationImageViews, Decoration.items).forEach { imageView, item in
            item.apply(to: imageView, scale: scale)
            imageView.center = CGPoint(
                x: calloutFrame.minX + imageView.center.x,
                y: calloutFrame.minY + imageView.center.y
            )
        }
    }

    private func setLayout() {
        calloutView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(Layout.topInset)
            $0.height.equalTo(Layout.calloutHeight)
        }
    }
}
