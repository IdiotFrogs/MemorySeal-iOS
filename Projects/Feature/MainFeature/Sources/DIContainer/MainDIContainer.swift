//
//  MainDIContainer.swift
//  MainFeature
//
//  Created by 선민재 on 4/13/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseData
import TicketData
import TicketDomain

public final class MainDIContainer {
    public init() {}

    func makeLandingUseCase() -> LandingUseCase {
        let ticketDetailProvider = DefaultProvider<TicketDetailTargetType>()
        let ticketDetailRepository = DefaultTicketDetailRepository(provider: ticketDetailProvider)
        let ticketDetailUseCase = DefaultTicketDetailUseCase(ticketDetailRepository: ticketDetailRepository)

        let joinCapsuleProvider = DefaultProvider<JoinCapsuleTargetType>()
        let joinCapsuleRepository = DefaultJoinCapsuleRepository(provider: joinCapsuleProvider)
        let joinCapsuleUseCase = DefaultJoinCapsuleUseCase(joinCapsuleRepository: joinCapsuleRepository)

        return DefaultLandingUseCase(
            ticketDetailUseCase: ticketDetailUseCase,
            joinCapsuleUseCase: joinCapsuleUseCase
        )
    }
}
