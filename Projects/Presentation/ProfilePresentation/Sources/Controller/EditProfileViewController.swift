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

import DesignSystem

public final class EditProfileViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: EditProfileViewModel

    // MARK: - Header

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필")
        return view
    }()

    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.setTitleColor(DesignSystemAsset.ColorAssests.grey2.color, for: .normal)
        return button
    }()

    // MARK: - Profile Image Section

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

    // MARK: - Nickname Section

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

    // MARK: - Init

    public init(with viewModel: EditProfileViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        addSubviews()
        setLayout()
        bindViewModel()
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Bind

extension EditProfileViewController {
    private func bindViewModel() {
        let input = EditProfileViewModel.Input(
            backButtonDidTap: navigationView.backButtonDidTap
        )
        let _ = viewModel.translation(input)
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
    }
}
