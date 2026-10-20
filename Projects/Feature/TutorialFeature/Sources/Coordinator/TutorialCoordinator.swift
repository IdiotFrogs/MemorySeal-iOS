//
//  TutorialCoordinator.swift
//  TutorialFeature
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import UIKit

import TutorialPresentation

public final class TutorialCoordinator {
    public struct Dependency {
        public let tutorialDidFinish: () -> Void

        public init(tutorialDidFinish: @escaping () -> Void) {
            self.tutorialDidFinish = tutorialDidFinish
        }
    }

    private let navigationController: UINavigationController
    private let tutorialDIContainer: TutorialDIContainer = TutorialDIContainer()
    private let dependency: Dependency

    public init(with navigationController: UINavigationController, dependency: Dependency) {
        self.navigationController = navigationController
        self.dependency = dependency
    }

    public func start() {
        let vmAction = TutorialViewModel.Action(
            tutorialDidFinish: dependency.tutorialDidFinish
        )
        let tutorialViewController = tutorialDIContainer.makeTutorialViewController(action: vmAction)

        self.navigationController.navigationBar.isHidden = true
        self.navigationController.pushViewController(tutorialViewController, animated: true)
    }
}
