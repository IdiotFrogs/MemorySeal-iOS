//
//  ManageTicketMenuRowView.swift
//  MemoryPresentation
//
//  Created by 선민재 on 4/7/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class ManageTicketMenuRowView: UIControl {
    // MARK: - Icon
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    // MARK: - Title
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = UIColor(red: 0x1A / 255.0, green: 0x1A / 255.0, blue: 0x1A / 255.0, alpha: 1.0)
        return label
    }()

    public var tap: ControlEvent<Void> {
        return ControlEvent(events: rx.controlEvent(.touchUpInside))
    }

    public init(iconName: String, title: String) {
        super.init(frame: .zero)

        iconImageView.image = UIImage(
            named: iconName,
            in: DesignSystemResources.bundle,
            with: nil
        )
        titleLabel.text = title

        addSubviews()
        setLayout()
        setupHighlightFeedback()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ManageTicketMenuRowView {
    private func addSubviews() {
        addSubview(iconImageView)
        addSubview(titleLabel)
    }

    private func setLayout() {
        snp.makeConstraints {
            $0.height.equalTo(72)
        }

        iconImageView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(16)
            $0.centerY.equalToSuperview()
            $0.trailing.lessThanOrEqualToSuperview()
        }
    }

    private func setupHighlightFeedback() {
        addTarget(self, action: #selector(handleTouchDown), for: [.touchDown])
        addTarget(self, action: #selector(handleTouchUp), for: [.touchUpInside, .touchUpOutside, .touchCancel])
    }

    @objc private func handleTouchDown() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 0.6
        }
    }

    @objc private func handleTouchUp() {
        UIView.animate(withDuration: 0.1) {
            self.alpha = 1.0
        }
    }
}
