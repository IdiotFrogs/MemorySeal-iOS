//
//  ProfileViewController.swift
//  ProfilePresentation
//
//  Created by 선민재 on 7/21/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Kingfisher

import DesignSystem
import BaseDomain

public final class ProfileViewController: UIViewController {

    private enum Text {
        static let withdrawalTitle: String = "회원탈퇴"
        static let withdrawalMessage: String = "메실 회원을 탈퇴를 위해 “회원탈퇴”를 입력해주세요."
        static let withdrawalCaption: String = "티켓에 저장된 내용은 삭제되지 않습니다."
        static let withdrawalConfirmText: String = "회원탈퇴"
        static let withdrawal: String = "탈퇴"
        static let cancel: String = "취소"
    }


    private enum Layout {
        static let profileImageSize: CGFloat = 80
        static let cardHorizontalInset: CGFloat = 20
        static let cardVerticalPadding: CGFloat = 8
        static let cardRowSpacing: CGFloat = 12
        static let cardRowHeight: CGFloat = 56
        static let cardRowHorizontalInset: CGFloat = 4
    }

    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: ProfileViewModel

    private let rxViewDidLoad: PublishRelay<Void> = .init()
    private let logoutConfirmDidTap: PublishRelay<Void> = .init()
    private let withdrawalConfirmDidTap: PublishRelay<Void> = .init()

    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        view.setTitle("프로필")
        return view
    }()

    // MARK: - Profile

    private let profileSectionView = UIView()

    private let userProfileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = Layout.profileImageSize / 2
        imageView.clipsToBounds = true
        imageView.image = DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    private let nickNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.bold.font(size: 24)
        label.textAlignment = .center
        return label
    }()

    private let editProfileButton = EditProfileButton()

    // MARK: - Card

    private let cardBackgroundView: WavyStrokeView = {
        let view = WavyStrokeView(
            style: .filled(color: DesignSystemAsset.ColorAssests.backgroundNormal.color)
        )
        view.waveCornerRadius = 16
        view.waveSpacing = 14
        view.waveAmplitude = 3
        view.isUserInteractionEnabled = false
        return view
    }()

    private let cardStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = Layout.cardRowSpacing
        stackView.alignment = .fill
        return stackView
    }()

    private let appVersionRowView = UIView()

    private let appVersionTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "앱 버전"
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        return label
    }()

    private let appVersionValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        return label
    }()

    private let termsOfServiceButton: DisclosureButton = {
        return DisclosureButton(
            title: "이용 약관",
            titleColor: DesignSystemAsset.ColorAssests.grey5.color
        )
    }()

    private let logoutButton: DisclosureButton = {
        return DisclosureButton(
            title: "로그아웃",
            titleColor: DesignSystemAsset.ColorAssests.grey5.color
        )
    }()

    private let withdrawalButton: DisclosureButton = {
        return DisclosureButton(
            title: "회원탈퇴",
            titleColor: DesignSystemAsset.ColorAssests.grey5.color
        )
    }()

    public init(with viewModel: ProfileViewModel) {
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
        bindButtons()

        rxViewDidLoad.accept(())
    }

    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}

// MARK: - Setup

extension ProfileViewController {
    private func setInitialValues() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        appVersionValueLabel.text = "v\(version ?? "")"
    }
}

// MARK: - Bind

extension ProfileViewController {
    private func bindViewModel() {
        let input = ProfileViewModel.Input(
            viewDidLoad: rxViewDidLoad,
            backButtonDidTap: navigationView.backButtonDidTap,
            editProfileButtonDidTap: editProfileButton.rx.tap,
            termsOfServiceDidTap: termsOfServiceButton.rx.tap,
            logoutConfirmDidTap: logoutConfirmDidTap.asObservable(),
            withdrawalConfirmDidTap: withdrawalConfirmDidTap.asObservable()
        )
        let output = viewModel.translation(input)

        output.userInfo
            .drive(with: self, onNext: { (self, user) in
                guard let user else { return }
                self.nickNameLabel.text = user.nickname

                if let url = URL(string: user.profileImageUrl) {
                    self.userProfileImageView.kf.setImage(with: url)
                }
            })
            .disposed(by: disposeBag)

        viewModel.withdrawalFailureSignal
            .emit(with: self, onNext: { (self, _) in
                ToastView.show(on: self.view, message: "회원 탈퇴에 실패했습니다. 다시 시도해주세요.", position: .top)
            })
            .disposed(by: disposeBag)
    }

    private func bindButtons() {
        logoutButton.rx.tap
            .subscribe(with: self, onNext: { (self, _) in
                self.showLogoutDialogView()
            })
            .disposed(by: disposeBag)

        withdrawalButton.rx.tap
            .subscribe(with: self, onNext: { (self, _) in
                self.showWithdrawalDialogView()
            })
            .disposed(by: disposeBag)
    }

    private func showLogoutDialogView() {
        let dialog = DialogView.show(
            on: view,
            title: "로그아웃",
            message: "메실에서 로그아웃 하시겠습니까?",
            cancelTitle: "유지",
            confirmTitle: "로그아웃"
        )

        dialog.confirmButtonDidTap
            .subscribe(with: self, onNext: { (self, _) in
                self.logoutConfirmDidTap.accept(())
            })
            .disposed(by: disposeBag)

        dialog.cancelButtonDidTap
            .subscribe(with: self, onNext: { (self, _) in
                dialog.dismiss()
            })
            .disposed(by: disposeBag)
    }

    private func showWithdrawalDialogView() {
        let dialog = DeleteConfirmDialogView.show(
            on: view,
            title: Text.withdrawalTitle,
            message: Text.withdrawalMessage,
            caption: Text.withdrawalCaption,
            placeholder: Text.withdrawalConfirmText,
            confirmText: Text.withdrawalConfirmText,
            cancelTitle: Text.cancel,
            confirmTitle: Text.withdrawal
        )

        dialog.confirmButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                dialog.dismiss()
                self.withdrawalConfirmDidTap.accept(())
            })
            .disposed(by: disposeBag)

        dialog.cancelButtonDidTap
            .subscribe(onNext: {
                dialog.dismiss()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Layout

extension ProfileViewController {
    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(profileSectionView)
        profileSectionView.addSubview(userProfileImageView)
        profileSectionView.addSubview(nickNameLabel)
        profileSectionView.addSubview(editProfileButton)

        view.addSubview(cardBackgroundView)
        view.addSubview(cardStackView)

        appVersionRowView.addSubview(appVersionTitleLabel)
        appVersionRowView.addSubview(appVersionValueLabel)

        cardStackView.addArrangedSubview(appVersionRowView)
        cardStackView.addArrangedSubview(termsOfServiceButton)
        cardStackView.addArrangedSubview(logoutButton)
        cardStackView.addArrangedSubview(withdrawalButton)
    }

    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(56)
        }

        profileSectionView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        userProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(Layout.profileImageSize)
        }

        nickNameLabel.snp.makeConstraints {
            $0.top.equalTo(userProfileImageView.snp.bottom).offset(8)
            $0.centerX.equalToSuperview()
            $0.leading.greaterThanOrEqualToSuperview().offset(20)
            $0.trailing.lessThanOrEqualToSuperview().inset(20)
        }

        editProfileButton.snp.makeConstraints {
            $0.top.equalTo(nickNameLabel.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(24)
        }

        cardBackgroundView.snp.makeConstraints {
            $0.top.equalTo(profileSectionView.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(Layout.cardHorizontalInset)
            $0.bottom.equalToSuperview()
        }

        cardStackView.snp.makeConstraints {
            $0.top.equalTo(cardBackgroundView).offset(Layout.cardVerticalPadding)
            $0.leading.trailing.equalTo(cardBackgroundView).inset(Layout.cardHorizontalInset)
        }

        appVersionRowView.snp.makeConstraints {
            $0.height.equalTo(Layout.cardRowHeight)
        }

        appVersionTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(Layout.cardRowHorizontalInset)
            $0.centerY.equalToSuperview()
        }

        appVersionValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(Layout.cardRowHorizontalInset)
            $0.centerY.equalToSuperview()
        }

        [termsOfServiceButton, logoutButton, withdrawalButton].forEach { button in
            button.snp.makeConstraints {
                $0.height.equalTo(Layout.cardRowHeight)
            }
        }
    }
}
