//
//  SignUpViewModel.swift
//  SignUpPresentation
//
//  Created by 선민재 on 3/4/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

import SignUpDomain

public final class SignUpViewModel {
    public struct Action {
        public let moveToHome: () -> Void

        public init(moveToHome: @escaping () -> Void) {
            self.moveToHome = moveToHome
        }
    }

    private let disposeBag = DisposeBag()
    private let signUpUseCase: SignUpUseCase
    public let action: Action

    private var selectedImage: UIImage?

    public init(signUpUseCase: SignUpUseCase, action: Action) {
        self.signUpUseCase = signUpUseCase
        self.action = action
    }

    struct Input {
        let imageSelected: PublishRelay<UIImage>
        let nickNameText: ControlProperty<String?>
        let doneButtonDidTap: ControlEvent<Void>
    }

    struct Output {
        let profileImage: PublishRelay<UIImage>
        let validationResult: PublishRelay<(isPassed: Bool, helpText: String?)>
        let isLoading: BehaviorRelay<Bool>
    }

    func transform(_ input: Input) -> Output {
        let profileImage = PublishRelay<UIImage>()
        let validationResult = PublishRelay<(isPassed: Bool, helpText: String?)>()
        let isLoading = BehaviorRelay<Bool>(value: false)

        input.imageSelected
            .withUnretained(self)
            .subscribe(onNext: { (self, image) in
                self.selectedImage = image
                profileImage.accept(image)
            })
            .disposed(by: disposeBag)

        input.doneButtonDidTap
            .withLatestFrom(input.nickNameText)
            .withUnretained(self)
            .subscribe(onNext: { (self, nickname) in
                let result = self.validate(nickname)
                validationResult.accept(result)

                guard result.isPassed, let nickname else { return }

                guard let profileImageData = self.selectedImage?.jpegData(compressionQuality: 0.8) else { return }

                self.requestSignUp(
                    nickname: nickname,
                    profileImage: profileImageData,
                    isLoading: isLoading
                )
            })
            .disposed(by: disposeBag)

        return Output(
            profileImage: profileImage,
            validationResult: validationResult,
            isLoading: isLoading
        )
    }
}

extension SignUpViewModel {
    private func validate(_ text: String?) -> (isPassed: Bool, helpText: String?) {
        guard let text, !text.isEmpty else {
            return (false, "별명을 입력하면 시작할 수 있습니다.")
        }

        guard text.trimmingCharacters(in: .whitespaces).isEmpty == false,
              text.count > 1,
              text.count < 17,
              text.last != " " else {
            return (false, "최소 1글자에서 16글자까지 입력할 수 있습니다.")
        }

        return (true, nil)
    }

    private func requestSignUp(
        nickname: String,
        profileImage: Data,
        isLoading: BehaviorRelay<Bool>
    ) {
        isLoading.accept(true)

        Task {
            do {
                try await signUpUseCase.execute(nickname: nickname, profileImage: profileImage)
                await MainActor.run {
                    isLoading.accept(false)
                    action.moveToHome()
                }
            } catch {
                await MainActor.run {
                    isLoading.accept(false)
                }
            }
        }
    }
}
