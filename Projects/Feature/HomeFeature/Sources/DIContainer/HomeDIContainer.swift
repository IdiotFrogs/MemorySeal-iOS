//
//  HomeDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation

import HomePresentation

public final class HomeDIContainer {
    func makeHomeTabmanViewController() -> HomeTabmanViewController {
        return HomeTabmanViewController(viewControllers: [
            makeHomeViewController(),
            makeHomeViewController()
        ])
    }
    
    private func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel()
    }
    
    func makeHomeViewController() -> HomeViewController {
        return HomeViewController(with: makeHomeViewModel())
    }
}
