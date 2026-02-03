//
//  AuthorizationPlugin.swift
//  BaseData
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Moya
import Foundation

final class AuthorizationPlugin: PluginType {
    static let shared = AuthorizationPlugin()
    
    private let keyChainStorage: KeyChainStorage
    
    private init() {
        self.keyChainStorage = DefaultKeyChainStorage()
    }
    
    func prepare(
        _ request: URLRequest,
        target: any TargetType
    ) -> URLRequest {
        guard let targetType = target as? BaseTargetType,
              targetType.isNeededAccessToken,
              let accessToken = keyChainStorage.read(forKey: .accessToken) else { return request }
        
        var request = request
        
        request.addValue(
            "Bearer \(accessToken)",
            forHTTPHeaderField: "Authorization"
        )
        
        return request
    }
}
