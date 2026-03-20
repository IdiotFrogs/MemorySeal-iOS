//
//  TimeCapsuleUseCase.swift
//  BaseDomain
//
//  Created by 선민재 on 3/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public protocol TimeCapsuleUseCase {
    func fetchMyTimeCapsules(role: TimeCapsuleRole) async throws -> [TimeCapsuleEntity]
}

public final class DefaultTimeCapsuleUseCase: TimeCapsuleUseCase {
    private let timeCapsuleRepository: TimeCapsuleRepository

    public init(timeCapsuleRepository: TimeCapsuleRepository) {
        self.timeCapsuleRepository = timeCapsuleRepository
    }

    public func fetchMyTimeCapsules(role: TimeCapsuleRole) async throws -> [TimeCapsuleEntity] {
        let allCapsules = try await timeCapsuleRepository.fetchMyTimeCapsules()

        return allCapsules.filter { capsule in
            capsule.timeCapsuleStatus != .opened && capsule.role == role
        }
    }
}
