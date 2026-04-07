//
//  ResultHandler.swift
//  BaseData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

import BaseDomain

public final class ResultHandler {
    public static func handleResult<T: Decodable, Error: DomainError>(
        result: Result<Response, MoyaError>,
        responseType: T.Type,
        errorType: Error.Type
    ) throws -> T {
        switch result {
        case .success(let response):
            switch response.statusCode {
            case 200..<300:
                return try response.map(responseType, using: JSONDecoder())
            default:
                let errorResponseDTO = try response.map(ErrorResponseDTO.self, using: JSONDecoder())
                throw Error.init(errorResponse: errorResponseDTO.toDomain)
            }
        case .failure(let error):
            guard let response = error.response else { throw error }
            if let errorResponseDTO = try? response.map(ErrorResponseDTO.self, using: JSONDecoder()) {
                throw Error.init(errorResponse: errorResponseDTO.toDomain)
            }
            throw error
        }
    }

    public static func handleResult<Error: DomainError>(
        result: Result<Response, MoyaError>,
        errorType: Error.Type
    ) throws {
        switch result {
        case .success(let response):
            switch response.statusCode {
            case 200..<300:
                return
            default:
                let errorResponseDTO = try response.map(ErrorResponseDTO.self, using: JSONDecoder())
                throw Error.init(errorResponse: errorResponseDTO.toDomain)
            }
        case .failure(let error):
            guard let response = error.response else { throw error }
            if let errorResponseDTO = try? response.map(ErrorResponseDTO.self, using: JSONDecoder()) {
                throw Error.init(errorResponse: errorResponseDTO.toDomain)
            }
            throw error
        }
    }
}
