//
//  CreateTicketResponseDTO.swift
//  CreateTicketData
//
//  Created by 선민재 on 3/17/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

struct CreateTicketResponseDTO: Decodable {
    let id: Int
    let title: String
    let description: String
    let openedAt: String
    let timeCapsuleStatus: String
    let mainImageUrl: String
}
