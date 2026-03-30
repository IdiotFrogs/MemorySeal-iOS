//
//  SettingsViewController.swift
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

public final class SettingsViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: SettingsViewModel
    
    private let logoutButtonDidTap: PublishRelay<Void> = .init()
    private let withdrawalConfirmDidTap: PublishRelay<Void> = .init()
    
    private let navigationView: MemorySealNavigationView = {
        let view = MemorySealNavigationView()
        return view
    }()
    
    private let rowsContainerView = UIView()
    
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
        label.text = "v0.2"
        label.textColor = DesignSystemAsset.ColorAssests.grey4.color
        label.font = DesignSystemFontFamily.Pretendard.regular.font(size: 16)
        return label
    }()
    
    private let termsOfServiceButton: DisclosureButton = {
        let button = DisclosureButton(
            title: "이용 약관",
            titleColor: DesignSystemAsset.ColorAssests.grey5.color
        )
        return button
    }()
    
    private let logoutButton: DisclosureButton = {
        let button = DisclosureButton(
            title: "로그아웃",
            titleColor: DesignSystemAsset.ColorAssests.grey5.color
        )
        return button
    }()
    
    private let withdrawalButton: DisclosureButton = {
        let button = DisclosureButton(
            title: "회원탈퇴",
            titleColor: DesignSystemAsset.ColorAssests.systemRed.color
        )
        return button
    }()
    
    public init(with viewModel: SettingsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        bindViewModel()
        bindButtons()
        
        addSubviews()
        setLayout()
    }
}

// MARK: - Bind

extension SettingsViewController {
    private func bindViewModel() {
        let input = SettingsViewModel.Input(
            backButtonDidTap: navigationView.backButtonDidTap,
            termsOfServiceDidTap: termsOfServiceButton.rx.tap,
            logoutButtonDidTap: logoutButtonDidTap.asObservable(),
            withdrawalDidTap: withdrawalConfirmDidTap.asObservable()
        )
        let _ = viewModel.translation(input)
    }
    
    private func bindButtons() {
        logoutButton.rx.tap
            .subscribe(with: self, onNext: { (self, _) in
                self.showLogoutDiaLogView()
            })
            .disposed(by: disposeBag)

        withdrawalButton.rx.tap
            .subscribe(with: self, onNext: { (self, _) in
                self.showWithdrawalDialogView()
            })
            .disposed(by: disposeBag)
    }
}

extension SettingsViewController {
    private func showLogoutDiaLogView() {
        let dialog = DialogView.show(
            on: view,
            title: "로그아웃",
            message: "메실에서 로그아웃 하시겠습니까?",
            cancelTitle: "유지",
            confirmTitle: "로그아웃"
        )
        
        dialog.confirmButtonDidTap
            .subscribe(with: self, onNext: { (self, _) in
                self.logoutButtonDidTap.accept(())
            })
            .disposed(by: disposeBag)
        
        dialog.cancelButtonDidTap
            .subscribe(with: self, onNext: { (self, _) in
                dialog.dismiss()
            })
            .disposed(by: disposeBag)
    }

    private func showWithdrawalDialogView() {
        let dialog = DialogView.show(
            on: view,
            title: "회원탈퇴",
            message: "메실 회원을 탈퇴하시겠습니까?\n티켓에 저장된 내용은 삭제되지 않습니다.",
            cancelTitle: "취소",
            confirmTitle: "탈퇴"
        )

        dialog.confirmButtonDidTap
            .subscribe(with: self, onNext: { (self, _) in
                self.withdrawalConfirmDidTap.accept(())
            })
            .disposed(by: disposeBag)

        dialog.cancelButtonDidTap
            .subscribe(with: self, onNext: { (self, _) in
                dialog.dismiss()
            })
            .disposed(by: disposeBag)
    }

    private func addSubviews() {
        view.addSubview(navigationView)
        view.addSubview(rowsContainerView)
        
        rowsContainerView.addSubview(appVersionRowView)
        appVersionRowView.addSubview(appVersionTitleLabel)
        appVersionRowView.addSubview(appVersionValueLabel)
        
        rowsContainerView.addSubview(termsOfServiceButton)
        rowsContainerView.addSubview(logoutButton)
        rowsContainerView.addSubview(withdrawalButton)
    }
    
    private func setLayout() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            $0.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            $0.height.equalTo(56)
        }
        
        rowsContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        appVersionRowView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(48)
        }
        
        appVersionTitleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        appVersionValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        termsOfServiceButton.snp.makeConstraints {
            $0.top.equalTo(appVersionRowView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(48)
        }
        
        logoutButton.snp.makeConstraints {
            $0.top.equalTo(termsOfServiceButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(48)
        }
        
        withdrawalButton.snp.makeConstraints {
            $0.top.equalTo(logoutButton.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(4)
            $0.height.equalTo(48)
            $0.bottom.equalToSuperview()
        }
    }
}
