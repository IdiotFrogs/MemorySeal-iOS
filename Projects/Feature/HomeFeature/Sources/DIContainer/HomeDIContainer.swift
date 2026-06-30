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
import BaseData
import BaseDomain
import HomeData
import HomeDomain

public final class HomeDIContainer {
    private func makeUserUseCase() -> UserUseCase {
        let provider = DefaultProvider<UserTargetType>()
        let repository = DefaultUserRepository(
            provider: provider,
            userDefaultStorage: DefaultUserDefaultStorage(),
            keyChainStorage: DefaultKeyChainStorage()
        )
        return DefaultUserUseCase(userRepository: repository)
    }

    func makeHomeTabmanViewModel(action: HomeTabmanViewModel.Action) -> HomeTabmanViewModel {
        return HomeTabmanViewModel(action: action, userUseCase: makeUserUseCase())
    }

    func makeHomeTabmanViewController(
        action: HomeTabmanViewModel.Action,
        viewControllers: [UIViewController]
    ) -> HomeTabmanViewController {
        return HomeTabmanViewController(
            viewControllers: viewControllers,
            with: makeHomeTabmanViewModel(action: action)
        )
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

    func makeHomeViewModel(action: HomeViewModel.Action, role: TimeCapsuleRole) -> HomeViewModel {
        let provider = DefaultProvider<HomeTargetType>()
        let repository = DefaultHomeRepository(provider: provider)
        let useCase = DefaultHomeUseCase(homeRepository: repository)
        return HomeViewModel(
            action: action,
            homeUseCase: useCase,
            role: role
        )
    }

    func makeHomeViewController(action: HomeViewModel.Action, role: TimeCapsuleRole) -> HomeViewController {
        return HomeViewController(with: makeHomeViewModel(action: action, role: role))
    }

    func makeHomeViewController(with viewModel: HomeViewModel) -> HomeViewController {
        return HomeViewController(with: viewModel)
    }

    private func makeEnterTicketViewModel() -> EnterTicketViewModel {
        let provider = DefaultProvider<EnterTicketTargetType>()
        let repository = DefaultEnterTicketRepository(provider: provider)
        let useCase = DefaultEnterTicketUseCase(enterTicketRepository: repository)
        return EnterTicketViewModel(enterTicketUseCase: useCase)
    }

    func makeEnterTicketViewController() -> EnterTicketViewController {
        return EnterTicketViewController(with: makeEnterTicketViewModel())
    }
}
