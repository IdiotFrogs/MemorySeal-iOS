//
//  EditProfileViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

import BaseDomain
import Foundation

public protocol EditProfileViewModelDelegate: AnyObject {
    func moveToBack()
}

public final class EditProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase

    let nickname: String
    let profileImageUrl: String

    public weak var delegate: EditProfileViewModelDelegate?

    public init(userUseCase: UserUseCase, nickname: String, profileImageUrl: String) {
        self.userUseCase = userUseCase
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
    }

    struct Input {
        let backButtonDidTap: ControlEvent<Void>
        let saveButtonDidTap: ControlEvent<Void>
        let nicknameText: ControlProperty<String?>
        let selectedProfileImage: BehaviorRelay<Data?>
    }

    struct Output {}

    func translation(_ input: Input) -> Output {
        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToBack()
            })
            .disposed(by: disposeBag)

        input.saveButtonDidTap
            .withLatestFrom(Observable.combineLatest(
                input.nicknameText.asObservable(),
                input.selectedProfileImage.asObservable()
            ))
            .withUnretained(self)
            .subscribe(onNext: { (self, args) in
                let (nicknameText, imageData) = args
                let nickname: String? = (nicknameText != self.nickname) ? nicknameText : nil

                self.editUserProfileInfo(nickname: nickname, profileImage: imageData)
            })
            .disposed(by: disposeBag)

        return Output()
    }
}

extension EditProfileViewModel {
    private func editUserProfileInfo(nickname: String?, profileImage: Data?) {
        Task {
            do {
                try await self.userUseCase.editProfile(
                    nickname: nickname,
                    profileImage: profileImage
                )
                await MainActor.run {
                    self.delegate?.moveToBack()
                }
            } catch {}
        }
    }
}
