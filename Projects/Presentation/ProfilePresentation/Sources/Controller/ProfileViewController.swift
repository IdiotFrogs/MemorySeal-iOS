//
//  ProfileViewController.swift
//  ProfilePresentation
//
//  Created by 선민재 on 7/21/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import DesignSystem

public final class ProfileViewController: UIViewController {
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필")
        return view
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("저장", for: .normal)
        button.titleLabel?.font = DesignSystemFontFamily.Pretendard.bold.font(size: 14)
        button.setTitleColor(DesignSystemAsset.ColorAssests.primaryNormal.color, for: .normal)
        return button
    }()
    
    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 17
        imageView.clipsToBounds = false
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
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
        label.text = "닉네임"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 12)
        return label
    }()
    
    private let nickNameTextField: UITextField = {
        let paddingView = UIView(frame: CGRect(
            x: 0,
            y: 0,
            width: 12,
            height: 0
        ))
        let textField = UITextField()
        textField.text = "유저 닉네임"
        textField.textColor = DesignSystemAsset.ColorAssests.grey5.color
        textField.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        textField.layer.cornerRadius = 12
        textField.layer.borderWidth = 1
        textField.layer.borderColor = DesignSystemAsset.ColorAssests.grey2.color.cgColor
        textField.leftView = paddingView
        textField.leftViewMode = .always
        return textField
    }()
    
    private let appVersionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "앱 버전"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        return label
    }()
    
    private let appVersionLabel: UILabel = {
        let label = UILabel()
        label.text = "V0.2"
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        return label
    }()
    
    private let termOfUseTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "이용 약관"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        return label
    }()
    
    private let termOfUseDisclosureButton = DisclosureButton(title: "이용 약관")
    
    private let withDrawalOfMembershipButton = DisclosureButton(
        title: "회원탈퇴",
        titleColor: DesignSystemAsset.ColorAssests.systemRed.color
    )
    
    private let signOutButton = DisclosureButton(title: "로그아웃")
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.addSubviews()
        self.setLayout()
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension ProfileViewController {
    private func addSubviews() {
        view.addSubview(navigationView)
        navigationView.addButton(saveButton)
        view.addSubview(userProfileImageView)
        view.addSubview(editProfileButton)
        view.addSubview(nickNameLabel)
        view.addSubview(nickNameTextField)
        view.addSubview(appVersionTitleLabel)
        view.addSubview(appVersionLabel)
        view.addSubview(termOfUseTitleLabel)
        view.addSubview(termOfUseDisclosureButton)
        view.addSubview(withDrawalOfMembershipButton)
        view.addSubview(signOutButton)
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
        
        userProfileImageView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120)
        }
        
        editProfileButton.snp.makeConstraints {
            $0.bottom.equalTo(userProfileImageView.snp.bottom).offset(4)
            $0.trailing.equalTo(userProfileImageView.snp.trailing).offset(4)
            $0.width.height.equalTo(40)
        }
        
        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImageView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        nickNameTextField.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        appVersionTitleLabel.snp.makeConstraints {
            $0.top.equalTo(nickNameTextField.snp.bottom).offset(28)
            $0.leading.equalToSuperview().offset(20)
        }
        
        appVersionLabel.snp.makeConstraints {
            $0.centerY.equalTo(appVersionTitleLabel.snp.centerY)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        termOfUseDisclosureButton.snp.makeConstraints {
            $0.top.equalTo(appVersionTitleLabel.snp.bottom).offset(28)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        withDrawalOfMembershipButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).inset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        signOutButton.snp.makeConstraints {
            $0.bottom.equalTo(withDrawalOfMembershipButton.snp.top)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
    }
}
