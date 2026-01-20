//
//  BaseTargetType.swift
//  BaseData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

public protocol BaseTargetType: TargetType {
    var baseURL: URL { get }
    var isNeededAccessToken: Bool { get }
}

public extension BaseTargetType {
    var baseURL: URL {
        return URL(string: "http://43.201.236.253:8080")!
    }
}
