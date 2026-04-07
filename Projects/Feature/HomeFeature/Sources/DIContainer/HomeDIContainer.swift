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

    func makeHomeViewModel(role: TimeCapsuleRole) -> HomeViewModel {
        return HomeViewModel(
            timeCapsuleUseCase: makeTimeCapsuleUseCase(),
            role: role
        )
    }

    func makeHomeViewController(viewModel: HomeViewModel) -> HomeViewController {
        return HomeViewController(with: viewModel)
    }

    func makeEnterTicketViewModel() -> EnterTicketViewModel {
        return EnterTicketViewModel(
            timeCapsuleUseCase: makeTimeCapsuleUseCase()
        )
    }

    func makeEnterTicketViewController(viewModel: EnterTicketViewModel) -> EnterTicketViewController {
        return EnterTicketViewController(with: viewModel)
    }
}
