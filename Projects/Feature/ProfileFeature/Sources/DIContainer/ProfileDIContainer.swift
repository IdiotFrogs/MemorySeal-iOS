//
//  ProfileDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 7/16/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import ProfilePresentation

public final class ProfileDIContainer {
    func makeProfileViewController() -> ProfileViewController {
        return ProfileViewController()
    }
}
