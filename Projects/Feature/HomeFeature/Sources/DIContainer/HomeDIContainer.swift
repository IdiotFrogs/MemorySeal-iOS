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

public final class HomeDIContainer {
    private func makeTimeCapsuleProvider() -> DefaultProvider<TimeCapsuleTargetType> {
        return DefaultProvider<TimeCapsuleTargetType>()
    }

    private func makeTimeCapsuleRepository() -> TimeCapsuleRepository {
        return DefaultTimeCapsuleRepository(
            provider: makeTimeCapsuleProvider()
        )
    }

    private func makeTimeCapsuleUseCase() -> TimeCapsuleUseCase {
        return DefaultTimeCapsuleUseCase(
            timeCapsuleRepository: makeTimeCapsuleRepository()
        )
    }

    private func makeHomeTabmanViewModel(action: HomeTabmanViewModel.Action) -> HomeTabmanViewModel {
        return HomeTabmanViewModel(action: action)
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

    private func makeHomeViewModel(action: HomeViewModel.Action, role: TimeCapsuleRole) -> HomeViewModel {
        return HomeViewModel(
            action: action,
            timeCapsuleUseCase: makeTimeCapsuleUseCase(),
            role: role
        )
    }

    func makeHomeViewController(action: HomeViewModel.Action, role: TimeCapsuleRole) -> HomeViewController {
        return HomeViewController(with: makeHomeViewModel(action: action, role: role))
    }

    private func makeEnterTicketViewModel() -> EnterTicketViewModel {
        return EnterTicketViewModel(
            timeCapsuleUseCase: makeTimeCapsuleUseCase()
        )
    }

    func makeEnterTicketViewController() -> EnterTicketViewController {
        return EnterTicketViewController(with: makeEnterTicketViewModel())
    }
}
