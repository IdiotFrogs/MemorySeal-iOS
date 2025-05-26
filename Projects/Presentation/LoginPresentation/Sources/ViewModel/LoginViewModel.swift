//
//  LoginViewModel.swift
//  LoginPresentation
//
//  Created by 선민재 on 5/13/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import RxSwift
import RxCocoa

public protocol LoginViewModelDelegate: AnyObject {
    func moveToHome()
    func moveToSignUp()
}

public final class LoginViewModel {
    private let disposeBag: DisposeBag = DisposeBag()
    
    public var delegate: LoginViewModelDelegate?
    
    public init() { }
    
    struct Input {
        let googleLoginButtonDidTap: ControlEvent<Void>
        let appleLoginButtonDidTap: PublishRelay<Void>
    }
    
    struct Output {
        
    }
    
    func translation(_ input: Input) -> Output {
        
        input.googleLoginButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToSignUp()
            })
            .disposed(by: disposeBag)
        
        input.appleLoginButtonDidTap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                self.delegate?.moveToHome()
            })
            .disposed(by: disposeBag)
        
        return Output()
    }
}
