//
//  DeleteConfirmDialogView.swift
//  DesignSystem
//
//  Created by 선민재 on 4/7/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public final class DeleteConfirmDialogView: UIView {
    private let disposeBag: DisposeBag = DisposeBag()

    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private let textField: UITextField = {
        let tf = UITextField()
        tf.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        tf.textColor = DesignSystemAsset.ColorAssests.grey5.color
        tf.layer.cornerRadius = 12
        tf.layer.borderWidth = 1
        tf.layer.borderColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        return tf
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
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.isEnabled = false
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
    private let confirmText: String

    public init(
        message: String,
        placeholder: String,
        confirmText: String,
        cancelTitle: String,
        confirmTitle: String
    ) {
        self.confirmText = confirmText
        super.init(frame: .zero)

        messageLabel.text = message
        textField.placeholder = placeholder
        cancelButton.setTitle(cancelTitle, for: .normal)
        confirmButton.setTitle(confirmTitle, for: .normal)

        self.backgroundColor = .white
        self.layer.cornerRadius = 24
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]

        self.addSubviews()
        self.setLayout()
        self.bindTextField()
        self.updateConfirmButtonState(isEnabled: false)
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindTextField() {
        textField.rx.text.orEmpty
            .map { [weak self] text in
                text == self?.confirmText
            }
            .subscribe(onNext: { [weak self] isMatch in
                self?.updateConfirmButtonState(isEnabled: isMatch)
            })
            .disposed(by: disposeBag)
    }

    private func updateConfirmButtonState(isEnabled: Bool) {
        confirmButton.isEnabled = isEnabled
        if isEnabled {
            confirmButton.backgroundColor = DesignSystemAsset.ColorAssests.systemRed.color
            confirmButton.setTitleColor(.white, for: .normal)
        } else {
            confirmButton.backgroundColor = DesignSystemAsset.ColorAssests.systemRed.color.withAlphaComponent(0.15)
            confirmButton.setTitleColor(
                DesignSystemAsset.ColorAssests.systemRed.color.withAlphaComponent(0.5),
                for: .normal
            )
        }
    }

    private var bottomConstraint: Constraint?

    @discardableResult
    public static func show(
        on view: UIView,
        message: String,
        placeholder: String,
        confirmText: String,
        cancelTitle: String,
        confirmTitle: String
    ) -> DeleteConfirmDialogView {
        let dialog = DeleteConfirmDialogView(
            message: message,
            placeholder: placeholder,
            confirmText: confirmText,
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
            $0.leading.trailing.equalToSuperview()
            dialog.bottomConstraint = $0.bottom.equalToSuperview().constraint
        }

        dialog.dimmingView = dimming
        view.layoutIfNeeded()

        dialog.transform = CGAffineTransform(translationX: 0, y: dialog.bounds.height + 300)

        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            dimming.alpha = 1
            dialog.transform = .identity
        }

        NotificationCenter.default.addObserver(
            dialog,
            selector: #selector(dialog.keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            dialog,
            selector: #selector(dialog.keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )

        dialog.textField.becomeFirstResponder()

        return dialog
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        bottomConstraint?.update(offset: -keyboardFrame.height)
        UIView.animate(withDuration: duration) {
            self.superview?.layoutIfNeeded()
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval
        else { return }

        bottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: duration) {
            self.superview?.layoutIfNeeded()
        }
    }

    public func dismiss(animated: Bool = true, completion: (() -> Void)? = nil) {
        textField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)

        let performDismiss = { [weak self] in
            self?.dimmingView?.removeFromSuperview()
            self?.removeFromSuperview()
            completion?()
        }

        guard animated else {
            performDismiss()
            return
        }

        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            self?.dimmingView?.alpha = 0
            self?.transform = CGAffineTransform(translationX: 0, y: self?.bounds.height ?? 300)
        }, completion: { _ in
            performDismiss()
        })
    }
}

extension DeleteConfirmDialogView {
    private func addSubviews() {
        addSubview(messageLabel)
        addSubview(textField)
        buttonStackView.addArrangedSubview(cancelButton)
        buttonStackView.addArrangedSubview(confirmButton)
        addSubview(buttonStackView)
    }

    private func setLayout() {
        messageLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(28)
            $0.leading.trailing.equalToSuperview().inset(24)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(messageLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }

        buttonStackView.snp.makeConstraints {
            $0.top.equalTo(textField.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
    }
}
