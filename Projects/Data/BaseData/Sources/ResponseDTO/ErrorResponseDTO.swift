//
//  ErrorResponseDTO.swift
//  BaseData
//
//  Created by 선민재 on 4/6/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import BaseDomain

struct ErrorResponseDTO: Decodable {
    let status: String?
    let error: String?
    let message: String?
    let path: String?

    var toDomain: ErrorResponseEntity {
        return .init(
            status: status ?? "",
            error: error ?? "",
            message: message ?? "",
            path: path ?? ""
        )
    }
}
