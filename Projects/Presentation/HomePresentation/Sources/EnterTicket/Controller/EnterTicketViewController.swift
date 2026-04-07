//
//  EnterTicketViewController.swift
//  HomePresentation
//
//  Created by 선민재 on 12/23/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import DesignSystem

public final class EnterTicketViewController: UIViewController {
    private let viewModel: EnterTicketViewModel
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let popUpBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        view.layer.cornerRadius = 24
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "참여코드를 입력해 타임 티켓에 합류해 보세요!"
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    private let codeTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "예. #23aef3wf923"
        textField.setPlaceholder(
            color: DesignSystemAsset.ColorAssests.grey3.color,
            font: DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        )
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 12
        textField.layer.borderColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
        textField.layer.borderWidth = 1
        return textField
    }()
    
    private let cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("취소", for: .normal)
        button.setTitleColor(
            DesignSystemAsset.ColorAssests.grey4.color,
            for: .normal
        )
        button.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.layer.cornerRadius = 12
        return button
    }()
    
    private let enterButton: UIButton = {
        let button = UIButton()
        button.setTitle("합류", for: .normal)
        button.setTitleColor(
            DesignSystemAsset.ColorAssests.grey3.color,
            for: .disabled
        )
        button.setTitleColor(
            .white,
            for: .normal
        )
        button.setBackgroundColor(
            color: DesignSystemAsset.ColorAssests.primaryLight.color,
            forState: .disabled
        )
        button.setBackgroundColor(
            color: DesignSystemAsset.ColorAssests.primaryNormal.color,
            forState: .normal
        )
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.layer.cornerRadius = 12
        button.isEnabled = false
        return button
    }()
    
    public init(with viewModel: EnterTicketViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.codeTextField.becomeFirstResponder()
        self.setBackgroundView()
        self.addSubViews()
        self.setLayout()
        self.observeKeyboardHeight()
        
        self.bindViewModel()
        self.bindButton()
        self.bindTextField()
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
}

extension EnterTicketViewController {
    private func observeKeyboardHeight() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let frame = notification.userInfo?[
                    UIResponder.keyboardFrameEndUserInfoKey
                ] as? CGRect else { return nil }
                
                return frame.height
            }
            .withUnretained(self)
            .subscribe(onNext: { (self, keyboardHeight) in
                self.keyboardWillShow(height: keyboardHeight)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
        let didTapEnterButton: PublishRelay<String> = .init()

        let input = EnterTicketViewModel.Input(
            didTapEnterButton: didTapEnterButton
        )
        let output = viewModel.transform(input)

        enterButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                guard let code = self.codeTextField.text, !code.isEmpty else { return }
                didTapEnterButton.accept(code)
            })
            .disposed(by: disposeBag)

        output.joinSuccess
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.dismiss(animated: true) {
                    guard let window = UIApplication.shared.connectedScenes
                        .compactMap({ $0 as? UIWindowScene })
                        .first?.windows.first else { return }
                    ToastView.show(on: window, message: "참여 코드 복사되었습니다.")
                }
            })
            .disposed(by: disposeBag)

        output.joinError
            .withUnretained(self)
            .subscribe(onNext: { (self, message) in
                let dialog = DialogView.show(
                    on: self.view,
                    title: "합류 실패",
                    message: message,
                    cancelTitle: "닫기",
                    confirmTitle: "확인"
                )
                dialog.cancelButtonDidTap
                    .subscribe(onNext: { _ in
                        dialog.dismiss()
                    })
                    .disposed(by: self.disposeBag)
                dialog.confirmButtonDidTap
                    .subscribe(onNext: { _ in
                        dialog.dismiss()
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindButton() {
        cancelButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindTextField() {
        codeTextField.rx.text.changed
            .withUnretained(self)
            .subscribe(onNext: { (self, content) in
                self.enterButton.isEnabled = !(content?.isEmpty ?? false)
            })
            .disposed(by: disposeBag)
    }
}

extension EnterTicketViewController {
    private func keyboardWillShow(height: CGFloat) {
        popUpBackgroundView.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(height)
            $0.leading.trailing.equalToSuperview()
        }
    }
    
    private func setBackgroundView() {
        view.backgroundColor = UIColor(
            red: 68 / 255,
            green: 68 / 255,
            blue: 68 / 255,
            alpha: 0.24
        )
    }
    
    private func addSubViews() {
        view.addSubview(popUpBackgroundView)
        popUpBackgroundView.addSubview(titleLabel)
        popUpBackgroundView.addSubview(codeTextField)
        popUpBackgroundView.addSubview(cancelButton)
        popUpBackgroundView.addSubview(enterButton)
    }
    
    private func setLayout() {
        popUpBackgroundView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.trailing.equalToSuperview()
        }
        
        codeTextField.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        cancelButton.snp.makeConstraints {
            $0.top.equalTo(codeTextField.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(48)
            $0.width.equalTo(80)
        }
        
        enterButton.snp.makeConstraints {
            $0.top.equalTo(codeTextField.snp.bottom).offset(24)
            $0.leading.equalTo(cancelButton.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(24)
            $0.height.equalTo(48)
        }
    }
}
