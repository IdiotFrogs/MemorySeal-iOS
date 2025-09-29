//
//  HomeDIContainer.swift
//  AppFeature
//
//  Created by 선민재 on 5/1/25.
//  Copyright © 2025 MemorySeal. All rights reserved.
//

import Foundation
import UIKit
import HomePresentation

public final class HomeDIContainer {
    func makeHomeTabmanViewModel() -> HomeTabmanViewModel {
        return HomeTabmanViewModel()
    }
    
    func makeHomeTabmanViewController(
        with viewModel: HomeTabmanViewModel,
        viewControllers: [UIViewController]
    ) -> HomeTabmanViewController {
        return HomeTabmanViewController(
            viewControllers: viewControllers,
            with: viewModel
        )
    }
    
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel()
    }
    
    func makeHomeViewController(viewModel: HomeViewModel) -> HomeViewController {
        return HomeViewController(with: viewModel)
    }
}
