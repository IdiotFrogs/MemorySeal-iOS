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
    func moveToEditProfile()
    func moveToSettings()
}

public final class ProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase

    public weak var delegate: ProfileViewModelDelegate?

    private let userInfo: PublishRelay<UserInfoEntity> = .init()

    struct Input {
        let viewDidLoad: PublishRelay<Void>
        let backButtonDidTap: ControlEvent<Void>
        let editProfileButtonDidTap: ControlEvent<Void>
        let settingButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let userInfo: Driver<UserInfoEntity>
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
                        self.userInfo.accept(user)
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
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToEditProfile()
            })
            .disposed(by: disposeBag)

        input.settingButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToSettings()
            })
            .disposed(by: disposeBag)

        return Output(userInfo: userInfo.asDriver(onErrorDriveWith: .empty()))
    }
}
