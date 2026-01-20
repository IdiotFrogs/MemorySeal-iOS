//
//  DomainError.swift
//  BaseDomain
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

public protocol DomainError: Error, Equatable {
    init()
}
