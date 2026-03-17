//
//  CreateTicketUseCase.swift
//  CreateTicketDomain
//
//  Created by 선민재 on 3/17/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

public protocol CreateTicketUseCase {
    func execute(
        title: String,
        description: String?,
        openedAt: Date,
        mainImage: Data
    ) async throws
}

public final class DefaultCreateTicketUseCase: CreateTicketUseCase {

    private let createTicketRepository: CreateTicketRepository

    public init(createTicketRepository: CreateTicketRepository) {
        self.createTicketRepository = createTicketRepository
    }

    public func execute(
        title: String,
        description: String?, 
        openedAt: Date,
        mainImage: Data
    ) async throws {
        try await createTicketRepository.createTicket(
            title: title,
            description: description,
            openedAt: openedAt,
            mainImage: mainImage
        )
    }
}
