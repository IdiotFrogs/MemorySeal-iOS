//
//  TutorialDIContainer.swift
//  TutorialFeature
//
//  Created by 선민재 on 10/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import TutorialPresentation

public final class TutorialDIContainer {

    public init() { }

    public func makeTutorialViewController(
        action: TutorialViewModel.Action
    ) -> TutorialViewController {
        return TutorialViewController(with: makeTutorialViewModel(action: action))
    }

    private func makeTutorialViewModel(action: TutorialViewModel.Action) -> TutorialViewModel {
        return TutorialViewModel(action: action)
    }
}
