//
//  TimeCapsuleRepository.swift
//  BaseDomain
//
//  Created by 선민재 on 3/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public protocol TimeCapsuleRepository {
    func fetchMyTimeCapsules() async throws -> [TimeCapsuleEntity]
    func inviteToTimeCapsule(capsuleId: Int) async throws -> String
    func joinRequest(code: String) async throws
    func deleteTimeCapsule(capsuleId: Int) async throws
    func fetchTimeCapsuleDetail(capsuleId: Int) async throws -> TimeCapsuleDetailEntity
    func fetchCollaborators(capsuleId: Int) async throws -> [CollaboratorEntity]
}
