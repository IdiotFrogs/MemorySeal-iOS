//
//  SignInViewController.swift
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
import GoogleSignIn

import DesignSystem

public final class SignInViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    private let viewModel: SignInViewModel
    
    private let appleAuthorizationCompleted: PublishRelay<(
        idToken: String,
        authorizationCode: String
    )> = .init()
    private let googleAuthorizationCompleted: PublishRelay<String> = .init()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "메실"
        label.font = DesignSystemFontFamily.Hs산토끼체20.regular.font(size: 56)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "익을수록 달콤한 기억"
        label.font = DesignSystemFontFamily.Pretendard.medium.font(size: 16)
        label.textColor = DesignSystemAsset.ColorAssests.grey5.color
        return label
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = DesignSystemAsset.ImageAssets.loginPageLogo.image
        return imageView
    }()
    
    private let appleSignInButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton(
            authorizationButtonType: .signIn,
            authorizationButtonStyle: .black
        )
        button.layer.cornerRadius = 24
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.black.cgColor
        button.clipsToBounds = true
        return button
    }()
        
    private let googleSignInButton = OAuthButton(oauthType: .google)
    
    public init(with viewModel: SignInViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(hex: "#F4F4CC")
        
        self.addSubViews()
        self.setLayout()
        
        self.bindViewModel()
        self.bindButtons()
    }
}

extension SignInViewController {
    private func bindViewModel() {
        let input = SignInViewModel.Input(
            appleAuthorizationCompleted: appleAuthorizationCompleted,
            googleAuthorizationCompleted: googleAuthorizationCompleted
        )
        let _ = viewModel.translation(input)
    }
    
    private func bindButtons() {
        appleSignInButton.rx.controlEvent(.touchUpInside)
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                let appleIDProvider = ASAuthorizationAppleIDProvider()
                let request = appleIDProvider.createRequest()
                request.requestedScopes = [.fullName, .email]
                
                let authorizationController = ASAuthorizationController(
                    authorizationRequests: [request]
                )
                authorizationController.delegate = self
                authorizationController.presentationContextProvider = self
                authorizationController.performRequests()
            })
            .disposed(by: disposeBag)
        
        googleSignInButton.rx.tap
            .withUnretained(self)
            .subscribe(onNext: { (self, _) in
                GIDSignIn.sharedInstance.signIn(
                    withPresenting: self
                ) { result, error in
                    guard error == nil,
                          let idToken = result?.user.idToken?.tokenString else { return }
                    
                    self.googleAuthorizationCompleted.accept(idToken)
                }
            })
            .disposed(by: disposeBag)
    }
}

extension SignInViewController: ASAuthorizationControllerDelegate {
    public func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
              let authorizationCode = appleIDCredential.authorizationCode,
              let identityToken = appleIDCredential.identityToken,
              let authorizationCodeString = String(data: authorizationCode, encoding: .utf8),
              let tokenString = String(data: identityToken, encoding: .utf8) else { return }
        
        appleAuthorizationCompleted.accept((
            idToken: tokenString,
            authorizationCode: authorizationCodeString
        ))
    }
}

extension SignInViewController: ASAuthorizationControllerPresentationContextProviding {
    public func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

extension SignInViewController {
    private func addSubViews() {
        view.addSubview(titleLabel)
        view.addSubview(subTitleLabel)
        view.addSubview(logoImageView)
        view.addSubview(appleSignInButton)
        view.addSubview(googleSignInButton)
    }
    
    private func setLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(84)
            $0.centerX.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
        }
        
        logoImageView.snp.makeConstraints {
            $0.top.equalTo(subTitleLabel.snp.bottom).offset(32)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(335)
            $0.height.equalTo(300)
        }
        
        appleSignInButton.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-24)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
        
        googleSignInButton.snp.makeConstraints {
            $0.bottom.equalTo(appleSignInButton.snp.top).offset(-16)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(48)
        }
    }
}
