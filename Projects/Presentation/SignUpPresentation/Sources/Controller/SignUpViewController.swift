//
//  SignUpViewController.swift
//  SplashFeature
//
//  Created by 선민재 on 5/01/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import UIKit
import SnapKit
import AuthenticationServices
import RxSwift
import RxCocoa

import DesignSystem

public final class SignUpViewController: UIViewController {
    private let disposeBag: DisposeBag = DisposeBag()
    
        
    public override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.cyan
        
        self.addSubViews()
        self.setLayout()
        
        self.bindButtons()
    }
}

extension SignUpViewController {
    private func bindButtons() {
        
    }
}

extension SignUpViewController {
    private func addSubViews() {
        
    }
    
    private func setLayout() {
        
    }
}
