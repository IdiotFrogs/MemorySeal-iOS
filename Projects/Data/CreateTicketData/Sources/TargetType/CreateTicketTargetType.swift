//
//  CreateTicketTargetType.swift
//  CreateTicketData
//
//  Created by 선민재 on 3/17/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

import BaseData

public enum CreateTicketTargetType {
    case createTicket(_ requestDTO: CreateTicketRequestDTO, mainImage: Data)
}

extension CreateTicketTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .createTicket:
            return "/time-capsules/create"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .createTicket:
            return .post
        }
    }

    public var task: Moya.Task {
        switch self {
        case let .createTicket(requestDTO, mainImage):
            let jsonData = (try? JSONEncoder().encode(requestDTO)) ?? Data()
            let dtoPart = MultipartFormData(
                provider: .data(jsonData),
                name: "timeCapsuleCreateDto",
                mimeType: "application/json"
            )
            let imagePart = MultipartFormData(
                provider: .data(mainImage),
                name: "mainImage",
                fileName: "main.jpg",
                mimeType: "image/jpeg"
            )
            return .uploadMultipart([dtoPart, imagePart])
        }
    }

    public var headers: [String: String]? {
        switch self {
        case .createTicket:
            return nil
        }
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .createTicket:
            return true
        }
    }
}
