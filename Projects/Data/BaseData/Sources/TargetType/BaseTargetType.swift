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
        guard let urlString = Bundle.main.object(forInfoDictionaryKey: "BASE_URL") as? String,
              let url = URL(string: urlString) else {
            fatalError("BASE_URL이 Info.plist에 없습니다.")
        }
        return url
    }
}
