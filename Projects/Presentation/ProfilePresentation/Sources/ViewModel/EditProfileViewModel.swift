//
//  EditProfileViewModel.swift
//  ProfilePresentation
//
//  Created by 선민재 on 3/16/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol EditProfileViewModelDelegate: AnyObject {
    func moveToBack()
}

public final class EditProfileViewModel {
    private let disposeBag: DisposeBag = DisposeBag()

    public weak var delegate: EditProfileViewModelDelegate?

    public init() {}

    struct Input {
        let backButtonDidTap: ControlEvent<Void>
    }

    struct Output {}

    func translation(_ input: Input) -> Output {
        input.backButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToBack()
            })
            .disposed(by: disposeBag)

        return Output()
    }
}
