//
//  RefreshResponseDTO.swift
//  BaseData
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//


struct RefreshResponseDTO: Decodable {
    let accessToken: String
    let refreshToken: String
}
