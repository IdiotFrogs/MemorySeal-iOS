//
//  TutorialPageIndicatorView.swift
//  TutorialPresentation
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit

final class TutorialPageIndicatorView: UIView {

    // MARK: - Properties

    private var dotViews: [UIView] = []
    private var dotWidthConstraints: [Constraint] = []
    private var currentPage: Int = 0

    // MARK: - UI

    private let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = TutorialMetrics.indicatorSpacing
        return stackView
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        setLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configure

    func configure(numberOfPages: Int) {
        dotViews.forEach { $0.removeFromSuperview() }
        dotViews.removeAll()
        dotWidthConstraints.removeAll()

        for _ in 0..<numberOfPages {
            let dotView = UIView()
            dotView.backgroundColor = TutorialMetrics.indicatorInactiveColor
            dotView.layer.cornerRadius = TutorialMetrics.indicatorDotSize / 2
            stackView.addArrangedSubview(dotView)
            dotView.snp.makeConstraints {
                $0.height.equalTo(TutorialMetrics.indicatorDotSize)
                dotWidthConstraints.append(
                    $0.width.equalTo(TutorialMetrics.indicatorDotSize).constraint
                )
            }
            dotViews.append(dotView)
        }

        applyCurrentPage(animated: false)
    }

    func setCurrentPage(_ page: Int, animated: Bool) {
        guard page != currentPage else { return }
        currentPage = page
        applyCurrentPage(animated: animated)
    }

    private func applyCurrentPage(animated: Bool) {
        for (index, dotView) in dotViews.enumerated() {
            let isActive = index == currentPage
            let width = isActive
                ? TutorialMetrics.indicatorActiveWidth
                : TutorialMetrics.indicatorDotSize
            dotWidthConstraints[index].update(offset: width)
            dotView.backgroundColor = isActive
                ? TutorialMetrics.indicatorActiveColor
                : TutorialMetrics.indicatorInactiveColor
        }

        guard animated else {
            layoutIfNeeded()
            return
        }

        UIView.animate(withDuration: 0.25) {
            self.layoutIfNeeded()
        }
    }
}

// MARK: - Subviews

extension TutorialPageIndicatorView {
    private func addSubviews() {
        addSubview(stackView)
    }

    private func setLayout() {
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
