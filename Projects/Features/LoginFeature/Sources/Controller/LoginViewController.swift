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
