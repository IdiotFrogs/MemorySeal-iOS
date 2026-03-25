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

public protocol ProfileViewModelDelegate: AnyObject {
    func moveToBack()
    func moveToEditProfile(nickname: String, profileImageUrl: String)
    func moveToSettings()
}

public final class ProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase

    public weak var delegate: ProfileViewModelDelegate?

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

    public init(userUseCase: UserUseCase) {
        self.userUseCase = userUseCase
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
                self.delegate?.moveToBack()
            })
            .disposed(by: disposeBag)

        input.editProfileButtonDidTap
            .withLatestFrom(userInfo.asObservable())
            .compactMap { $0 }
            .withUnretained(self)
            .subscribe(onNext: { (self, user) in
                self.delegate?.moveToEditProfile(nickname: user.nickname, profileImageUrl: user.profileImageUrl)
            })
            .disposed(by: disposeBag)

        input.settingButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToSettings()
            })
            .disposed(by: disposeBag)

        return Output(userInfo: userInfo.asDriver())
    }
}
