//
//  LoginViewController.swift
//  SplashFeature
//
//  Created by 선민재 on 10/28/24.
//  Copyright © 2024 MinSungJin. All rights reserved.
//

import UIKit
import SnapKit
import AuthenticationServices
import RxSwift
import RxCocoa

import DesignSystem

public final class LoginViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
    private let appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .continue,
            authorizationButtonStyle: .white
        )
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        return button
    }()
        
    private let googleSignInButton = OAuthButton(oauthType: .google)
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hex: "#121212")
        
        self.addSubViews()
        self.setLayout()
        
        self.bindButtons()
    }
}

extension LoginViewController {
    private func bindButtons() {
        appleSignInButton.rx.controlEvent(.touchUpInside)
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                
                let authorizationController = ASAuthorizationController(authorizationRequests: [request])
                authorizationController.delegate = self
                authorizationController.presentationContextProvider = self
                authorizationController.performRequests()
            })
            .disposed(by: disposeBag)
    }
}

extension LoginViewController: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let authorizationCode = appleIDCredential.authorizationCode,
              let identityToken = appleIDCredential.identityToken,
              let authorizationCodeString = String(data: authorizationCode, encoding: .utf8),
              let tokenString = String(data: identityToken, encoding: .utf8) else { return }
        
        print("🧊 appleIDCredential.user \(appleIDCredential.user)")
        print("🧊 tokenString \(tokenString)")
        print("🧊 authorizationCodeString \(authorizationCodeString)")


        // 유니크한 값
//        LoginCheckManager.shared.userAppleIdentity = appleIDCredential.user
//        LoginCheckManager.shared.userAppleIdentityToken = tokenString
//        LoginCheckManager.shared.userAppleAuthorizationCode = authorizationCodeString
        
//        Task {
//            do {
//                try await LoginCheckManager.shared.requestAuthKeys(signinType: .apple, token: authorizationCodeString)
//            } catch let error {
//                DispatchQueue.main.async {
//                    self.alertWith(message: error.localizedDescription)
//                }
//            }
//        }
        
    }
}

extension LoginViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension LoginViewController {
    private func addSubViews() {
        view.addSubview(appleSignInButton)
        view.addSubview(googleSignInButton)
    }
    
    private func setLayout() {
        
        appleSignInButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-16)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        googleSignInButton.snp.makeConstraints {
            $0.bottom.equalTo(appleSignInButton.snp.top).offset(-12)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
}
