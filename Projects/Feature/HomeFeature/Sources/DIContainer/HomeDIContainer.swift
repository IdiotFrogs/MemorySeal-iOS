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

    private func makeHomeUseCase() -> HomeUseCase {
        let provider = DefaultProvider<HomeTargetType>()
        let repository = DefaultHomeRepository(provider: provider)
        return DefaultHomeUseCase(homeRepository: repository)
    }

    func makeHomeContainerViewModel(action: HomeContainerViewModel.Action) -> HomeContainerViewModel {
        return HomeContainerViewModel(action: action, userUseCase: makeUserUseCase())
    }

    func makeHomeContainerViewController(
        with viewModel: HomeContainerViewModel,
        viewControllers: [UIViewController]
    ) -> HomeContainerViewController {
        return HomeContainerViewController(
            viewControllers: viewControllers,
            with: viewModel
        )
    }

    func makeHomeViewModel(action: HomeViewModel.Action) -> HomeViewModel {
        return HomeViewModel(
            action: action,
            homeUseCase: makeHomeUseCase()
        )
    }

    func makeHomeViewController(with viewModel: HomeViewModel) -> HomeViewController {
        return HomeViewController(with: viewModel)
    }

    func makeTicketListViewModel(
        kind: HomeSectionKind,
        action: TicketListViewModel.Action
    ) -> TicketListViewModel {
        return TicketListViewModel(
            kind: kind,
            homeUseCase: makeHomeUseCase(),
            action: action
        )
    }

    func makeTicketListViewController(with viewModel: TicketListViewModel) -> TicketListViewController {
        return TicketListViewController(with: viewModel)
    }

    func makeOpenedTicketViewModel(action: OpenedTicketViewModel.Action) -> OpenedTicketViewModel {
        return OpenedTicketViewModel(homeUseCase: makeHomeUseCase(), action: action)
    }

    func makeOpenedTicketViewController(with viewModel: OpenedTicketViewModel) -> OpenedTicketViewController {
        return OpenedTicketViewController(with: viewModel)
    }

    private func makeEnterTicketViewModel(action: EnterTicketViewModel.Action) -> EnterTicketViewModel {
        let provider = DefaultProvider<EnterTicketTargetType>()
        let repository = DefaultEnterTicketRepository(provider: provider)
        let useCase = DefaultEnterTicketUseCase(enterTicketRepository: repository)
        return EnterTicketViewModel(action: action, enterTicketUseCase: useCase)
    }

    func makeEnterTicketViewController(action: EnterTicketViewModel.Action) -> EnterTicketViewController {
        return EnterTicketViewController(with: makeEnterTicketViewModel(action: action))
    }
}
