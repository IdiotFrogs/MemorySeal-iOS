//
//  SignUpViewController.swift
//  SplashFeature
//
//  Created by 선민재 on 5/01/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import PhotosUI
import SnapKit
import RxSwift
import RxCocoa

import DesignSystem

public final class SignUpViewController: UIViewController {

    private let disposeBag: DisposeBag = DisposeBag()
    private let imageSelectedRelay: PublishRelay<UIImage> = .init()

    public let viewModel: SignUpViewModel

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
        textField.setPlaceholder(
            color: DesignSystemAsset.ColorAssests.grey3.color,
            font: DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        )
        return textField
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("이 프로필로 할게요!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = DesignSystemAsset.ColorAssests.primaryDark.color
        button.layer.cornerRadius = 12
        return button
    }()

    private let helpTextIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.helpTextIcon.image
        imageView.isHidden = true
        return imageView
    }()

    private let helpTextLabel: UILabel = {
        let label = UILabel()
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        label.textColor = DesignSystemAsset.ColorAssests.systemRed.color
        label.isHidden = true
        return label
    }()
    
    public init(with viewModel: SignUpViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color

        self.addSubViews()
        self.setLayout()
        self.bindViewModel()
        self.observeKeyboardHeight()
        self.setTextFieldDelegate()
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
    private func bindViewModel() {
        let input = SignUpViewModel.Input(
            imageSelected: imageSelectedRelay,
            nickNameText: nickNameTextField.rx.text,
            doneButtonDidTap: doneButton.rx.tap
        )

        let output = viewModel.transform(input)

        output.profileImage
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, image) in
                self.userProfileImageView.image = image
            })
            .disposed(by: disposeBag)

        output.validationResult
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, result) in
                self.helpTextIcon.isHidden = result.isPassed
                self.helpTextLabel.isHidden = result.isPassed
                self.helpTextLabel.text = result.helpText
            })
            .disposed(by: disposeBag)

        output.isLoading
            .observe(on: MainScheduler.instance)
            .withUnretained(self)
            .subscribe(onNext: { (self, isLoading) in
                self.doneButton.isEnabled = !isLoading
            })
            .disposed(by: disposeBag)

        navigationBarBackButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.navigationController?.popViewController(animated: true)
            })
            .disposed(by: disposeBag)

        editProfileButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.presentImagePicker()
            })
            .disposed(by: disposeBag)
    }

    private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.selectionLimit = 1
        config.filter = .images

        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
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
            .subscribe(onNext: { (self, _) in
                self.keyboardWillHide()
            })
            .disposed(by: disposeBag)
    }

    private func setTextFieldDelegate() {
        self.nickNameTextField.delegate = self
    }
}

extension SignUpViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)

        guard let provider = results.first?.itemProvider,
              provider.canLoadObject(ofClass: UIImage.self) else { return }

        provider.loadObject(ofClass: UIImage.self) { [weak self] object, _ in
            guard let self, let image = object as? UIImage else { return }
            DispatchQueue.main.async {
                self.imageSelectedRelay.accept(image)
            }
        }
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
        view.addSubview(helpTextIcon)
        view.addSubview(helpTextLabel)
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

        helpTextIcon.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(8)
            $0.leading.equalToSuperview().inset(20)
            $0.width.height.equalTo(16)
        }

        helpTextLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(9)
            $0.leading.equalTo(helpTextIcon.snp.trailing).offset(4)
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

extension SignUpViewController: UITextFieldDelegate {
    public func textField(
        _ textField: UITextField,
        shouldChangeCharactersIn range: NSRange,
        replacementString string: String
    ) -> Bool {
        let currentText = textField.text ?? ""
        let updatedText = (currentText as NSString).replacingCharacters(
            in: range,
            with: string
        )

        if currentText.isEmpty && updatedText == " " { return false }

        guard updatedText.contains("  ") == false else { return false }

        guard updatedText.count <= 16 else { return false }

        return true
    }

    public func textFieldDidBeginEditing(
        _ textField: UITextField
    ) {
        textField.layer.borderColor = DesignSystemAsset.ColorAssests.grey5.color.cgColor
    }

    public func textFieldDidEndEditing(
        _ textField: UITextField
    ) {
        textField.layer.borderColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
    }
}
