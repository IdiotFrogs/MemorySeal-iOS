//
//  DefaultTimeCapsuleRepository.swift
//  BaseData
//
//  Created by 선민재 on 3/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Moya

import BaseDomain

public final class DefaultTimeCapsuleRepository: TimeCapsuleRepository {

    private let provider: DefaultProvider<TimeCapsuleTargetType>

    public init(provider: DefaultProvider<TimeCapsuleTargetType>) {
        self.provider = provider
    }

    public func fetchMyTimeCapsules() async throws -> [TimeCapsuleEntity] {
        let result = await provider.request(.fetchMyTimeCapsules)

        let responseDTOs = try ResultHandler.handleResult(
            result: result,
            responseType: [TimeCapsuleResponseDTO].self,
            errorType: TimeCapsuleError.self
        )

        return responseDTOs.map { $0.toDomain }
    }

    public func joinRequest(code: String) async throws {
        let result = await provider.request(.joinRequest(code: code))
        try ResultHandler.handleResult(result: result, errorType: TimeCapsuleError.self)
    }

    public func inviteToTimeCapsule(capsuleId: Int) async throws -> String {
        let result = await provider.request(.inviteToTimeCapsule(capsuleId: capsuleId))

        let responseDTO = try ResultHandler.handleResult(
            result: result,
            responseType: InviteCodeResponseDTO.self,
            errorType: TimeCapsuleError.self
        )

        return responseDTO.code
    }

    public func deleteTimeCapsule(capsuleId: Int) async throws {
        let result = await provider.request(.deleteTimeCapsule(capsuleId: capsuleId))
        try ResultHandler.handleResult(result: result, errorType: TimeCapsuleError.self)
    }
}
