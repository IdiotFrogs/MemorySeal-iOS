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
    private let resetProfileImage: BehaviorRelay<Bool> = .init(value: false)

    private var nicknameWavyLayer: WavyStrokeLayer?

    // MARK: - Navigation

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필 수정")
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.setTitleColor(UIColor(hex: "#84B591"), for: .disabled)
        button.setTitleColor(DesignSystemAsset.ColorAssests.primaryDark.color, for: .normal)
        button.backgroundColor = DesignSystemAsset.ColorAssests.primaryLight.color
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
        return button
    }()

    // MARK: - Profile Image

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

    private let editImageButton = UIButton()

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
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()

    private let nicknameHelperLabel: UILabel = {
        let label = UILabel()
        label.isHidden = true
        label.numberOfLines = 0
        return label
    }()

    private let maximumNicknameLength: Int = 16

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
        setupWavyStroke()
        bindViewModel()

        bottomSheetView.transform = CGAffineTransform(translationX: 0, y: bottomSheetHeight)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        guard let nicknameWavyLayer else { return }
        if nicknameWavyLayer.frame != nicknameTextField.bounds {
            nicknameWavyLayer.frame = nicknameTextField.bounds
        }
        nicknameWavyLayer.setNeedsPathRefresh()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    private func setInitialValues() {
        nicknameTextField.text = viewModel.nickname
        if let url = URL(string: viewModel.profileImageUrl) {
            userProfileImageView.kf.setImage(with: url)
            photoPlaceholderImageView.isHidden = true
        } else {
            photoPlaceholderImageView.isHidden = false
        }
    }

    private func setupWavyStroke() {
        nicknameWavyLayer = nicknameTextField.addWavyStrokeLayer(
            strokeColor: DesignSystemAsset.ColorAssests.grey2.color,
            lineWidth: 3,
            cornerRadius: 12,
            alignment: .outside
        )
    }
}

// MARK: - Bind

extension EditProfileViewController {
    private func bindViewModel() {
        let input = EditProfileViewModel.Input(
            backButtonDidTap: navigationView.backButtonDidTap,
            saveButtonDidTap: saveButton.rx.tap,
            nicknameText: nicknameTextField.rx.text,
            selectedProfileImage: selectedProfileImage,
            resetProfileImage: resetProfileImage
        )
        let output = viewModel.translation(input)

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
                    self.userProfileImageView.image = nil
                    self.photoPlaceholderImageView.isHidden = false
                    self.selectedProfileImage.accept(nil)
                    self.resetProfileImage.accept(true)
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

        nicknameTextField.rx.text.orEmpty
            .distinctUntilChanged()
            .withUnretained(self)
            .bind { (self, text) in
                if text.count > self.maximumNicknameLength {
                    self.showNicknameError(
                        "최소 1글자에서 \(self.maximumNicknameLength)글자까지 입력할 수 있습니다.",
                        isTextInvalid: true
                    )
                } else {
                    self.hideNicknameError()
                }
            }
            .disposed(by: disposeBag)

        output.saveError
            .emit(with: self, onNext: { (self, message) in
                self.showNicknameError(message, isTextInvalid: false)
            })
            .disposed(by: disposeBag)
    }

    private func showNicknameError(_ message: String, isTextInvalid: Bool) {
        nicknameHelperLabel.attributedText = makeHelperText(message)
        nicknameHelperLabel.isHidden = false
        nicknameTextField.textColor = isTextInvalid
            ? .red
            : DesignSystemAsset.ColorAssests.grey5.color
    }

    private func hideNicknameError() {
        nicknameHelperLabel.isHidden = true
        nicknameTextField.textColor = DesignSystemAsset.ColorAssests.grey5.color
    }

    private func makeHelperText(_ message: String) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        attachment.image = UIImage(systemName: "exclamationmark.circle.fill", withConfiguration: config)?
            .withTintColor(.red, renderingMode: .alwaysOriginal)
        let result = NSMutableAttributedString(attachment: attachment)
        result.append(
            NSAttributedString(
                string: " " + message,
                attributes: [
                    .foregroundColor: UIColor.red,
                    .font: DesignSystemFontFamily.Pretendard.regular.font(size: 12)
                ]
            )
        )
        return result
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
        photoPlaceholderImageView.isHidden = true
        selectedProfileImage.accept(imageData)
        resetProfileImage.accept(false)
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
        userProfileImageView.addSubview(photoPlaceholderImageView)
        profileContainerView.addSubview(editBadgeWavyView)
        editBadgeWavyView.addSubview(editPencilImageView)
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
            $0.height.equalTo(32)
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

        editImageButton.snp.makeConstraints {
            $0.edges.equalTo(editBadgeWavyView)
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
