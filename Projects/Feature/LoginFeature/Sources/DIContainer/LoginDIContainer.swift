//
//  LoginDIContainer.swift
//  LoginFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import LoginPresentation

//public protocol LoginDIContainer {
//    func makeLoginViewController() -> LoginViewController
//}

public final class LoginDIContainer {
    func makeLoginViewController() -> LoginViewController {
        return LoginViewController()
    }
}
