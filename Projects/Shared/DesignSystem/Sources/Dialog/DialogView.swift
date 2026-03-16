//
//  DialogView.swift
//  DesignSystem
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public final class DialogView: UIView {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 20)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.numberOfLines = 0
        return label
    }()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.numberOfLines = 0
        return label
    }()

    private let textStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey4.color, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.backgroundColor = DesignSystemAsset.ColorAssests.primaryNormal.color
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        return button
    }()

    private let buttonStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 8
        stack.distribution = .fillEqually
        return stack
    }()

    public var cancelButtonDidTap: ControlEvent<Void> {
        return cancelButton.rx.tap
    }

    public var confirmButtonDidTap: ControlEvent<Void> {
        return confirmButton.rx.tap
    }

    private weak var dimmingView: UIView?

    public init(
        title: String,
        message: String,
        cancelTitle: String,
        confirmTitle: String
    ) {
        super.init(frame: .zero)
        titleLabel.text = title
        messageLabel.text = message
        cancelButton.setTitle(cancelTitle, for: .normal)
        confirmButton.setTitle(confirmTitle, for: .normal)

        self.backgroundColor = .white
        self.layer.cornerRadius = 24

        self.addSubviews()
        self.setLayout()
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @discardableResult
    public static func show(
        on view: UIView,
        title: String,
        message: String,
        cancelTitle: String,
        confirmTitle: String
    ) -> DialogView {
        let dialog = DialogView(
            title: title,
            message: message,
            cancelTitle: cancelTitle,
            confirmTitle: confirmTitle
        )

        let dimming = UIView()
        dimming.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimming.alpha = 0
        view.addSubview(dimming)
        dimming.snp.makeConstraints { $0.edges.equalToSuperview() }

        view.addSubview(dialog)
        dialog.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }

        dialog.dimmingView = dimming
        dialog.alpha = 0
        dialog.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)

        UIView.animate(withDuration: 0.25) {
            dimming.alpha = 1
            dialog.alpha = 1
            dialog.transform = .identity
        }

        return dialog
    }

    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        let performDismiss = { [weak self] in
            self?.dimmingView?.removeFromSuperview()
            self?.removeFromSuperview()
            completion?()
        }

        guard animated else {
            performDismiss()
            return
        }

        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.dimmingView?.alpha = 0
            self?.alpha = 0
        }, completion: { _ in
            performDismiss()
        })
    }
}

extension DialogView {
    private func addSubviews() {
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(messageLabel)

        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)

        addSubview(textStackView)
        addSubview(buttonStackView)
    }

    private func setLayout() {
        textStackView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(textStackView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
    }
}
