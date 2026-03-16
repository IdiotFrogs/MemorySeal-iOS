//
//  ProfileViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol ProfileViewModelDelegate: AnyObject {
    func moveToBack()
    func moveToEditProfile()
}

public final class ProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public weak var delegate: ProfileViewModelDelegate?

    public init() {}

    struct Input {
        let backButtonDidTap: ControlEvent<Void>
        let editProfileButtonDidTap: ControlEvent<Void>
    }

    struct Output {}

    func translation(_ input: Input) -> Output {
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

        return Output()
    }
}
