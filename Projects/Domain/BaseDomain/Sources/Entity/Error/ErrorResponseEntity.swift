//
//  ErrorResponseEntity.swift
//  BaseDomain
//
//  Created by 선민재 on 4/6/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

public struct ErrorResponseEntity: Equatable {
    public let status: String
    public let error: String
    public let message: String
    public let path: String

    public init(status: String, error: String, message: String, path: String) {
        self.status = status
        self.error = error
        self.message = message
        self.path = path
    }
}
