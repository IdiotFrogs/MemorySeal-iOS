//
//  HomeCalloutHeaderView.swift
//  HomePresentation
//
//  Created by 선민재 on 9/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import SnapKit

final class HomeCalloutHeaderView: UICollectionReusableView {

    static let elementKind: String = UICollectionView.elementKindSectionHeader
    static let identifier: String = String(describing: HomeCalloutHeaderView.self)
    static let height: CGFloat = Layout.topInset + Layout.calloutHeight + Layout.bottomInset

    private enum Layout {
        static let topInset: CGFloat = 12
        static let calloutHeight: CGFloat = 43
        static let bottomInset: CGFloat = 25
    }

    // MARK: - Views

    private let calloutView: OpenableCalloutView = {
        let view = OpenableCalloutView(frame: .zero)
        return view
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.addSubviews()
        self.setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Layout

extension HomeCalloutHeaderView {
    private func addSubviews() {
        addSubview(calloutView)
    }

    private func setLayout() {
        calloutView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(Layout.topInset)
            $0.height.equalTo(Layout.calloutHeight)
        }
    }
}
