//
//  SignUpViewController.swift
//  SplashFeature
//
//  Created by 선민재 on 5/01/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import AuthenticationServices
import RxSwift
import RxCocoa

import DesignSystem

public final class SignUpViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let navigationBarBackButton: UIButton = {
        let button = UIButton()
        button.setImage(
            DesignSystemAsset.ImageAssets.navigationBarBackButton.image,
            for: .normal
        )
        return button
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "프로필"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 24)
        label.textAlignment = .left
        return label
    }()
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.layer.cornerRadius = 64
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let editProfileButton: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 20
        button.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        button.setImage(DesignSystemAsset.ImageAssets.editIcon.image, for: .normal)
        return button
    }()
    
    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.text = "별명"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        label.textAlignment = .left
        return label
    }()
    
    private let nickNameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = DesignSystemAsset.ColorAssests.grey5.color
        textField.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        textField.placeholder = "별명을 입력해주세요."
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.rightViewMode = .always
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("이 프로필로 할게요!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = DesignSystemAsset.ColorAssests.grey5.color
        button.layer.cornerRadius = 12
        return button
    }()
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        
        self.addSubViews()
        self.setLayout()
        
        self.bindButtons()
        self.bindTextField()
        self.observeKeyboardHeight()
        
    }
    
    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.view.endEditing(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension SignUpViewController {
    private func bindButtons() {
        navigationBarBackButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindTextField() {
        nickNameTextField.rx.text.changed
            .distinctUntilChanged()
            .distinctUntilChanged()
            .scan("") { (text, changedText) in
                let textMaxCount: Int = 200
                let changedTextCount: Int = changedText?.filter { $0 != "\n" }.count ?? 0
                                
                guard changedTextCount <= textMaxCount else { return text }
                
                return changedText ?? ""
            }
            .withUnretained(self)
            .bind { (self, text) in
                self.nickNameTextField.text = text
                
                if text.isEmpty {
                    self.nickNameTextField.layer.borderColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
                } else {
                    self.nickNameTextField.layer.borderColor = DesignSystemAsset.ColorAssests.grey5.color.cgColor
                }
//                self.commentInputView.setStatus(isCountEmpty: text.isEmpty)
            }
            .disposed(by: disposeBag)
    }
    
    private func observeKeyboardHeight() {
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                guard let frame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return nil }
                return frame.height
            }
            .withUnretained(self)
            .subscribe(onNext: { (self, keyboardHeight) in
                self.keyboardWillShow(height: keyboardHeight)
            })
            .disposed(by: disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
            .map { _ in 0 }
            .withUnretained(self)
            .subscribe(onNext: { (self, keyboardHeight) in
                self.keyboardWillHide()
            })
            .disposed(by: disposeBag)
    }
}

extension SignUpViewController {
    private func addSubViews() {
        view.addSubview(navigationBarBackButton)
        view.addSubview(titleLabel)
        view.addSubview(userProfileImageView)
        view.addSubview(editProfileButton)
        view.addSubview(nickNameLabel)
        view.addSubview(nickNameTextField)
        view.addSubview(doneButton)
    }
    
    private func setLayout() {
        navigationBarBackButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(navigationBarBackButton.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        userProfileImageView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(128)
        }
        
        editProfileButton.snp.makeConstraints {
            $0.bottom.equalTo(userProfileImageView.snp.bottom).offset(4)
            $0.trailing.equalTo(userProfileImageView.snp.trailing).offset(4)
            $0.width.height.equalTo(40)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImageView.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        doneButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
    
    private func keyboardWillShow(height: CGFloat) {
        doneButton.snp.remakeConstraints {
            $0.bottom.equalToSuperview().inset(height)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(48)
        }
        
        doneButton.layer.cornerRadius = 0
    }
    
    private func keyboardWillHide() {
        doneButton.snp.remakeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        doneButton.layer.cornerRadius = 12
    }
}
