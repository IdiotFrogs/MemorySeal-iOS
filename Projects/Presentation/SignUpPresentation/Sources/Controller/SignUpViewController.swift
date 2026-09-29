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
    private var nicknameWavyLayer: WavyStrokeLayer?

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

    private let profileContainerView = UIView()

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.backgroundColor = DesignSystemAsset.ColorAssests.grey1.color
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let photoPlaceholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.photoIcon.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = DesignSystemAsset.ColorAssests.grey3.color
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private let editBadgeWavyView: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.grey5.color,
            strokeColor: DesignSystemAsset.ColorAssests.grey5.color,
            lineWidth: 2
        )
        view.waveCornerRadius = 20
        view.isUserInteractionEnabled = false
        return view
    }()

    private let editPencilImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.editPencilIcon.image.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private let editProfileButton = UIButton()

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

    private let doneButtonWavyBackground: WavyStrokeView = {
        let view = WavyStrokeView(
            fillColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            strokeColor: DesignSystemAsset.ColorAssests.primaryNormal.color,
            lineWidth: 3
        )
        view.waveCornerRadius = 12
        view.strokeAlignment = .outside
        view.isUserInteractionEnabled = false
        return view
    }()

    private let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("이 프로필로 할게요!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 16)
        button.backgroundColor = .clear
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
        self.setupWavyStroke()
        self.bindViewModel()
        self.observeKeyboardHeight()
        self.setTextFieldDelegate()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        syncWavyStrokeLayer(nicknameWavyLayer, to: nickNameTextField.bounds)
    }

    private func setupWavyStroke() {
        nicknameWavyLayer = nickNameTextField.addWavyStrokeLayer(
            strokeColor: DesignSystemAsset.ColorAssests.grey2.color,
            lineWidth: 3,
            cornerRadius: 12,
            alignment: .outside
        )
    }

    private func syncWavyStrokeLayer(_ layer: WavyStrokeLayer?, to bounds: CGRect) {
        guard let layer else { return }
        if layer.frame != bounds {
            layer.frame = bounds
        }
        layer.setNeedsPathRefresh()
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
                self.photoPlaceholderImageView.isHidden = true
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
                self.imageSelectedRelay.accept(image.squareCropped(maxDimension: 1024))
            }
        }
    }
}

extension SignUpViewController {
    private func addSubViews() {
        view.addSubview(navigationBarBackButton)
        view.addSubview(titleLabel)
        view.addSubview(profileContainerView)
        profileContainerView.addSubview(userProfileImageView)
        userProfileImageView.addSubview(photoPlaceholderImageView)
        profileContainerView.addSubview(editBadgeWavyView)
        editBadgeWavyView.addSubview(editPencilImageView)
        profileContainerView.addSubview(editProfileButton)
        view.addSubview(nickNameLabel)
        view.addSubview(nickNameTextField)
        view.addSubview(doneButtonWavyBackground)
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

        profileContainerView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(19)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(128)
        }

        userProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }

        photoPlaceholderImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(44)
        }

        editBadgeWavyView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        editPencilImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(20)
        }

        editProfileButton.snp.makeConstraints {
            $0.edges.equalTo(editBadgeWavyView)
        }

        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(profileContainerView.snp.bottom).offset(24)
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

        doneButtonWavyBackground.snp.makeConstraints {
            $0.edges.equalTo(doneButton)
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

        doneButtonWavyBackground.snp.remakeConstraints {
            $0.top.leading.trailing.equalTo(doneButton)
            $0.bottom.equalTo(doneButton).offset(12)
        }

        doneButtonWavyBackground.waveCornerRadius = 0
    }

    private func keyboardWillHide() {
        doneButton.snp.remakeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        doneButtonWavyBackground.snp.remakeConstraints {
            $0.edges.equalTo(doneButton)
        }

        doneButtonWavyBackground.waveCornerRadius = 12
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
