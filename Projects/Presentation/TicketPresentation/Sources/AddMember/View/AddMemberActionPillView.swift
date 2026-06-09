//
//  AddMemberActionPillView.swift
//  TicketPresentation
//
//  Created by 선민재 on 6/1/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

final class AddMemberActionPillView: UIControl {
    private let wavyBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: UIColor(hex: "#CFF2D8") ?? .systemGreen,
            strokeColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let iconImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        label.textColor = UIColor(hex: "#048F27") ?? .systemGreen
        label.textAlignment = .center
        return label
    }()

    private let contentStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.spacing = 4
        stack.isUserInteractionEnabled = false
        return stack
    }()

    var tap: ControlEvent<Void> {
        return ControlEvent(events: rx.controlEvent(.touchUpInside))
    }

    init(icon: UIImage?, title: String) {
        super.init(frame: .zero)

        iconImageView.image = icon
        titleLabel.text = title

        self.addSubviews()
        self.setLayout()
        self.setupHighlightFeedback()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension AddMemberActionPillView {
    private func addSubviews() {
        addSubview(wavyBackground)

        contentStackView.addArrangedSubview(iconImageView)
        contentStackView.addArrangedSubview(titleLabel)
        addSubview(contentStackView)
    }

    private func setLayout() {
        wavyBackground.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentStackView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(12)
            $0.trailing.lessThanOrEqualToSuperview().inset(18)
            $0.top.greaterThanOrEqualToSuperview().offset(12)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }

        iconImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
    }

    private func setupHighlightFeedback() {
        addTarget(self, action: #selector(handleTouchDown), for: [.touchDown])
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.7
        }
    }

    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
}
