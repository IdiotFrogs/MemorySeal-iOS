//
//  CreateTicketRepository.swift
//  CreateTicketDomain
//
//  Created by 선민재 on 3/17/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public protocol CreateTicketRepository {
    func createTicket(title: String, description: String?, openedAt: Date, mainImage: Data) async throws
}
