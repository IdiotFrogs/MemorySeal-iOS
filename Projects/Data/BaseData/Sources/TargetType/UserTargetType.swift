//
//  UserTargetType.swift
//  AuthData
//
//  Created by 선민재 on 1/20/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

public enum UserTargetType {
    case userInfo
    case uploadProfileImage(userId: Int, file: String)
    case editProfile(nickname: String, profileImage: Data?)
    case deleteAccount
}

extension UserTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .userInfo, .editProfile, .deleteAccount:
            return "/users/me"
        case .uploadProfileImage:
            return "/s3/upload/profile-image"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .userInfo:
            return .get
        case .uploadProfileImage:
            return .post
        case .editProfile:
            return .put
        case .deleteAccount:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .userInfo:
            return .requestPlain
        case .uploadProfileImage(let userId, let file):
            return .requestCompositeParameters(
                bodyParameters: ["file": file],
                bodyEncoding: JSONEncoding.default,
                urlParameters: ["userId": userId]
            )
        case .deleteAccount:
            return .requestPlain
        case .editProfile(let nickname, let profileImage):
            if let imageData = profileImage {
                let multipartData = [MultipartFormData(
                    provider: .data(imageData),
                    name: "profileImage",
                    fileName: "profile.jpg",
                    mimeType: "image/jpeg"
                )]
                return .uploadCompositeMultipart(multipartData, urlParameters: ["nickname": nickname])
            } else {
                return .requestParameters(
                    parameters: ["nickname": nickname],
                    encoding: URLEncoding.queryString
                )
            }
        }
    }

    public var headers: [String : String]? {
        return nil
    }

    public var validationType: ValidationType {
        return .successCodes
    }

    public var isNeededAccessToken: Bool {
        return true
    }
}
