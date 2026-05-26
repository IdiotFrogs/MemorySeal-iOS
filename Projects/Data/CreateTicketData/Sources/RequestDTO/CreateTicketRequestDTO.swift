//
//  CreateTicketRequestDTO.swift
//  CreateTicketData
//
//  Created by 선민재 on 3/17/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct CreateTicketRequestDTO: Encodable {
    let title: String
    let description: String?

    public init(title: String, description: String?) {
        self.title = title
        self.description = description
    }
}
