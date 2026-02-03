//
//  DefaultProvider.swift
//  BaseData
//
//  Created by 선민재 on 2/3/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

public final class DefaultProvider<T: TargetType>: MoyaProvider<T> {
    public init(timeoutInterval: TimeInterval = 15.0) {
        let requestClosure = { (endPoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            do {
                var request = try endPoint.urlRequest()
                request.timeoutInterval = timeoutInterval
                done(.success(request))
            } catch MoyaError.requestMapping(let url) {
                done(.failure(MoyaError.requestMapping(url)))
            } catch MoyaError.parameterEncoding(let error){
                done(.failure(MoyaError.parameterEncoding(error)))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        }
        
        let interceptor: RequestInterceptor = AuthorizationInterceptor.shared
        let authorizationPlugin: PluginType = AuthorizationPlugin.shared

        super.init(
            requestClosure: requestClosure,
            session: Session(interceptor: interceptor),
            plugins: [authorizationPlugin]
        )
    }
}
