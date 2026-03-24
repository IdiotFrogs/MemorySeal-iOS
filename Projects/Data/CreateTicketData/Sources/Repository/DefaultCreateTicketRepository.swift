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
        openedAt: Date,
        mainImage: Data
    ) async throws {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"

        let requestDTO = CreateTicketRequestDTO(
            title: title,
            description: description,
            openedAt: dateFormatter.string(from: openedAt)
        )
        
        print(requestDTO)

        let result = await provider.request(.createTicket(requestDTO, mainImage: mainImage))

        try ResultHandler.handleResult(
            result: result,
            errorType: CreateTicketError.self
        )
    }
}
