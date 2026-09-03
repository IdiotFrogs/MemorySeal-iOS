//
//  ProfileViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

import BaseDomain
import SignInDomain

public final class ProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase
    private let authUseCase: AuthUseCase

    public struct Action {
        public let moveToBack: () -> Void
        public let moveToEditProfile: (_ nickname: String, _ profileImageUrl: String) -> Void
        public let moveToTermsOfService: () -> Void
        public let didLogout: () -> Void
        public let didWithdraw: () -> Void

        public init(
            moveToBack: @escaping () -> Void,
            moveToEditProfile: @escaping (_ nickname: String, _ profileImageUrl: String) -> Void,
            moveToTermsOfService: @escaping () -> Void,
            didLogout: @escaping () -> Void,
            didWithdraw: @escaping () -> Void
        ) {
            self.moveToBack = moveToBack
            self.moveToEditProfile = moveToEditProfile
            self.moveToTermsOfService = moveToTermsOfService
            self.didLogout = didLogout
            self.didWithdraw = didWithdraw
        }
    }
    public let action: Action

    private let userInfo: BehaviorRelay<UserInfoEntity?> = .init(value: nil)
    private let refreshRelay: PublishRelay<Void> = .init()

    public func refresh() {
        refreshRelay.accept(())
    }

    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
        let editProfileButtonDidTap: ControlEvent<Void>
        let termsOfServiceDidTap: ControlEvent<Void>
        let logoutConfirmDidTap: Observable<Void>
        let withdrawalConfirmDidTap: Observable<Void>
    }

    struct Output {
        let userInfo: Driver<UserInfoEntity?>
    }

    public init(userUseCase: UserUseCase, authUseCase: AuthUseCase, action: Action) {
        self.userUseCase = userUseCase
        self.authUseCase = authUseCase
        self.action = action
    }

    func translation(_ input: Input) -> Output {
        Observable.merge(
            input.viewDidLoad.asObservable(),
            refreshRelay.asObservable()
        )
        .withUnretained(self)
        .subscribe(onNext: { (self, _) in
            self.fetchUserInfo()
        })
        .disposed(by: disposeBag)

        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        input.editProfileButtonDidTap
            .withLatestFrom(userInfo.asObservable())
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { (self, user) in
                self.action.moveToEditProfile(user.nickname, user.profileImageUrl)
            })
            .disposed(by: disposeBag)

        input.termsOfServiceDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToTermsOfService()
            })
            .disposed(by: disposeBag)

        input.logoutConfirmDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestSignOut()
            })
            .disposed(by: disposeBag)

        input.withdrawalConfirmDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.requestDeleteAccount()
            })
            .disposed(by: disposeBag)

        return Output(userInfo: userInfo.asDriver())
    }
}

extension ProfileViewModel {
    private func fetchUserInfo() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let user = try await self.userUseCase.fetchUserInfo()
                await MainActor.run {
                    self.userInfo.accept(user)
                }
            } catch {}
        }
    }

    private func requestSignOut() {
        Task { [weak self] in
            guard let self else { return }
            try? await self.authUseCase.executeLogout()
            await MainActor.run { [weak self] in
                self?.action.didLogout()
            }
        }
    }

    private func requestDeleteAccount() {
        Task { [weak self] in
            guard let self else { return }
            try? await self.userUseCase.deleteAccount()
            await MainActor.run { [weak self] in
                self?.action.didWithdraw()
            }
        }
    }
}
