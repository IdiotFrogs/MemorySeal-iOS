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

public final class EditProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    private let userUseCase: UserUseCase

    let nickname: String
    let profileImageUrl: String

    private let maximumNicknameLength: Int = 16

    public struct Action {
        public let moveToBack: () -> Void
        public let didEditProfile: () -> Void

        public init(
            moveToBack: @escaping () -> Void,
            didEditProfile: @escaping () -> Void
        ) {
            self.moveToBack = moveToBack
            self.didEditProfile = didEditProfile
        }
    }
    public let action: Action

    private let saveErrorRelay: PublishRelay<String> = .init()

    public init(userUseCase: UserUseCase, action: Action, nickname: String, profileImageUrl: String) {
        self.userUseCase = userUseCase
        self.action = action
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
    }

    struct Input {
        let backButtonDidTap: ControlEvent<Void>
        let saveButtonDidTap: ControlEvent<Void>
        let nicknameText: ControlProperty<String?>
        let selectedProfileImage: BehaviorRelay<Data?>
        let resetProfileImage: BehaviorRelay<Bool>
    }

    struct Output {
        let saveError: Signal<String>
    }

    func translation(_ input: Input) -> Output {
        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.action.moveToBack()
            })
            .disposed(by: disposeBag)

        input.saveButtonDidTap
            .withLatestFrom(Observable.combineLatest(
                input.nicknameText.orEmpty.asObservable(),
                input.selectedProfileImage.asObservable(),
                input.resetProfileImage.asObservable()
            ))
            .withUnretained(self)
            .subscribe(onNext: { (self, args) in
                let (nicknameText, imageData, resetProfileImage) = args

                guard nicknameText.count <= self.maximumNicknameLength else {
                    return
                }

                let nicknameChanged = nicknameText != self.nickname && !nicknameText.isEmpty
                let imageChanged = imageData != nil

                guard nicknameChanged || imageChanged || resetProfileImage else {
                    self.saveErrorRelay.accept("이미 사용 중인 별명입니다.")
                    return
                }

                self.editUserProfileInfo(
                    nickname: nicknameChanged ? nicknameText : nil,
                    profileImage: imageData,
                    resetProfileImage: resetProfileImage
                )
            })
            .disposed(by: disposeBag)

        return Output(saveError: saveErrorRelay.asSignal())
    }
}

extension EditProfileViewModel {
    private func editUserProfileInfo(nickname: String?, profileImage: Data?, resetProfileImage: Bool) {
        Task {
            do {
                try await self.userUseCase.editProfile(
                    nickname: nickname,
                    profileImage: profileImage,
                    resetProfileImage: resetProfileImage
                )
                await MainActor.run {
                    self.action.didEditProfile()
                    self.action.moveToBack()
                }
            } catch {}
        }
    }
}
