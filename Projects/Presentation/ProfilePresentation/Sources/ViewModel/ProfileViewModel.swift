//
//  ProfileViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import BaseDomain

public final class ProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase

    public struct Action {
        public let moveToBack: () -> Void
        public let moveToEditProfile: (_ nickname: String, _ profileImageUrl: String) -> Void
        public let moveToSettings: () -> Void

        public init(moveToBack: @escaping () -> Void, moveToEditProfile: @escaping (_ nickname: String, _ profileImageUrl: String) -> Void, moveToSettings: @escaping () -> Void) {
            self.moveToBack = moveToBack
            self.moveToEditProfile = moveToEditProfile
            self.moveToSettings = moveToSettings
        }
    }
    public let action: Action

    private let userInfo: BehaviorRelay<UserInfoEntity?> = .init(value: nil)

    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
        let editProfileButtonDidTap: ControlEvent<Void>
        let settingButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let userInfo: Driver<UserInfoEntity?>
    }

    public init(userUseCase: UserUseCase, action: Action) {
        self.userUseCase = userUseCase
        self.action = action
    }

    func translation(_ input: Input) -> Output {
        input.viewDidLoad
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                Task {
                    do {
                        let user = try await self.userUseCase.fetchUserInfo()
                        await MainActor.run {
                            self.userInfo.accept(user)
                        }
                    } catch {}
                }
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

        input.settingButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToSettings()
            })
            .disposed(by: disposeBag)

        return Output(userInfo: userInfo.asDriver())
    }
}
