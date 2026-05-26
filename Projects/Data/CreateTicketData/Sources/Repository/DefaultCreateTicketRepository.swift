//
//  DefaultCreateTicketRepository.swift
//  CreateTicketData
//
//  Created by 선민재 on 3/17/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseData
import CreateTicketDomain

public final class DefaultCreateTicketRepository: CreateTicketRepository {

    private let provider: DefaultProvider<CreateTicketTargetType>

    public init(provider: DefaultProvider<CreateTicketTargetType>) {
        self.provider = provider
    }

    public func createTicket(
        title: String,
        description: String?,
        mainImage: Data
    ) async throws {

        let requestDTO = CreateTicketRequestDTO(
            title: title,
            description: description
        )
        
        let result = await provider.request(.createTicket(requestDTO, mainImage: mainImage))

        try ResultHandler.handleResult(
            result: result,
            errorType: CreateTicketError.self
        )
    }
}
