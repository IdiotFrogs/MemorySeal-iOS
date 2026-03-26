//
//  EditProfileViewController.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

import DesignSystem

public final class EditProfileViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: EditProfileViewModel

    private let selectedProfileImage: BehaviorRelay<Data?> = .init(value: nil)

    // MARK: - Navigation

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필")
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.setTitleColor(
            DesignSystemAsset.ColorAssests.grey2.color,
            for: .disabled
        )
        button.setTitleColor(
            DesignSystemAsset.ColorAssests.primaryNormal.color,
            for: .normal
        )
        button.isEnabled = false
        return button
    }()

    // MARK: - Profile Image

    private let profileContainerView = UIView()

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 60
        imageView.clipsToBounds = true
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let editImageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = DesignSystemAsset.ColorAssests.backgroundNormal.color
        button.layer.cornerRadius = 20
        button.setImage(
            DesignSystemAsset.ImageAssets.editIcon.image.withRenderingMode(.alwaysTemplate),
            for: .normal
        )
        button.tintColor = DesignSystemAsset.ColorAssests.grey3.color
        return button
    }()

    // MARK: - Nickname

    private let nicknameTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "닉네임"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()

    private let nicknameTextField: UITextField = {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        let textField = UITextField()
        textField.textColor = DesignSystemAsset.ColorAssests.grey5.color
        textField.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()

    private let nicknameHelperLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true

        let attachment = NSTextAttachment()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        attachment.image = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: config)?
            .withTintColor(.red, renderingMode: .alwaysOriginal)
        let imageString = NSAttributedString(attachment: attachment)
        let textString = NSAttributedString(
            string: " 최소 1글자에서 16글자까지 입력할 수 있습니다.",
            attributes: [
                .foregroundColor: UIColor.red,
                .font: DesignSystemFontFamily.Pretendard.regular.font(size: 12)
            ]
        )
        let result = NSMutableAttributedString()
        result.append(imageString)
        result.append(textString)
        label.attributedText = result
        return label
    }()

    // MARK: - Bottom Sheet

    private let dimmingView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        view.alpha = 0
        view.isUserInteractionEnabled = true
        return view
    }()

    private let bottomSheetView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 16
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()

    private let selectFromAlbumButton: UIButton = {
        let button = UIButton()
        button.setTitle("앨범에서 이미지 선택", for: .normal)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey5.color, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        button.contentHorizontalAlignment = .left
        return button
    }()

    private let dashedSeparator = DashedLineView()

    private let applyDefaultImageButton: UIButton = {
        let button = UIButton()
        button.setTitle("기본 이미지 적용", for: .normal)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey5.color, for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        button.contentHorizontalAlignment = .left
        return button
    }()

    private let bottomSheetHeight: CGFloat = 152

    public init(with viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        setInitialValues()
        addSubviews()
        setLayout()
        bindViewModel()

        bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func setInitialValues() {
        nicknameTextField.text = viewModel.nickname
        if let url = URL(string: viewModel.profileImageUrl) {
            userProfileImageView.kf.setImage(with: url)
        }
    }
}

// MARK: - Bind

extension EditProfileViewController {
    private func bindViewModel() {
        let input = EditProfileViewModel.Input(
            backButtonDidTap: navigationView.backButtonDidTap,
            saveButtonDidTap: saveButton.rx.tap,
            nicknameText: nicknameTextField.rx.text,
            selectedProfileImage: selectedProfileImage
        )
        let _ = viewModel.translation(input)

        editImageButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.showBottomSheet()
            })
            .disposed(by: disposeBag)

        selectFromAlbumButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.hideBottomSheet {
                    self.presentImagePicker()
                }
            })
            .disposed(by: disposeBag)

        applyDefaultImageButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.hideBottomSheet {
                    self.userProfileImageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
                    self.selectedProfileImage.accept(nil)
                }
            })
            .disposed(by: disposeBag)

        let tapDimming = UITapGestureRecognizer()
        dimmingView.addGestureRecognizer(tapDimming)
        tapDimming.rx.event
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.hideBottomSheet(completion: nil)
            })
            .disposed(by: disposeBag)

        nicknameTextField.rx.controlEvent(.editingChanged)
            .withLatestFrom(nicknameTextField.rx.text.orEmpty)
            .distinctUntilChanged()
            .scan((validatedText: "", isLimitExceeded: false)) { previous, newText in
                guard newText.count <= 16 else {
                    return (previous.validatedText, true)
                }
                return (newText, false)
            }
            .withUnretained(self)
            .bind { (self, result) in
                let isInvalid = result.validatedText.isEmpty || result.isLimitExceeded
                let saveButtonIsInvalid = result.validatedText.isEmpty
                self.nicknameHelperLabel.isHidden = !isInvalid
                self.saveButton.isEnabled = !saveButtonIsInvalid
                
                self.nicknameTextField.text = result.validatedText
            }
            .disposed(by: disposeBag)
    }

    private func showBottomSheet() {
        bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
            self.dimmingView.alpha = 1
            self.bottomSheetView.transform = .identity
        }
    }

    private func hideBottomSheet(completion: (() -> Void)?) {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.dimmingView.alpha = 0
            self.bottomSheetView.transform = CGAffineTransform(translationX: 0, y: self.bottomSheetHeight)
        }, completion: { _ in
            completion?()
        })
    }

    private func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(
        _ picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
        picker.dismiss(animated: true)

        let image = (info[.editedImage] ?? info[.originalImage]) as? UIImage
        guard let image,
              let imageData = image.jpegData(compressionQuality: 0.8) else { return }

        userProfileImageView.image = image
        selectedProfileImage.accept(imageData)
    }

    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Layout

extension EditProfileViewController {
    private func addSubviews() {
        view.addSubview(navigationView)
        navigationView.addButton(saveButton)

        view.addSubview(profileContainerView)
        profileContainerView.addSubview(userProfileImageView)
        profileContainerView.addSubview(editImageButton)

        view.addSubview(nicknameTitleLabel)
        view.addSubview(nicknameTextField)
        view.addSubview(nicknameHelperLabel)

        view.addSubview(dimmingView)
        view.addSubview(bottomSheetView)
        bottomSheetView.addSubview(selectFromAlbumButton)
        bottomSheetView.addSubview(dashedSeparator)
        bottomSheetView.addSubview(applyDefaultImageButton)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(56)
        }

        saveButton.snp.makeConstraints {
            $0.height.equalTo(24)
            $0.width.greaterThanOrEqualTo(24)
        }

        profileContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(128)
        }

        userProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(4)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }

        editImageButton.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.width.height.equalTo(40)
        }

        nicknameTitleLabel.snp.makeConstraints {
            $0.top.equalTo(profileContainerView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        nicknameTextField.snp.makeConstraints {
            $0.top.equalTo(nicknameTitleLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }

        nicknameHelperLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameTextField.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        dimmingView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        bottomSheetView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(bottomSheetHeight)
        }

        selectFromAlbumButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }

        dashedSeparator.snp.makeConstraints {
            $0.top.equalTo(selectFromAlbumButton.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }

        applyDefaultImageButton.snp.makeConstraints {
            $0.top.equalTo(dashedSeparator.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52)
        }
    }
}
