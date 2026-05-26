import Foundation
import Moya

import BaseData

public enum CapsuleContentTargetType {
    case fetchCapsuleContents(capsuleId: Int)
    case createTextContent(capsuleId: Int, request: CreateContentRequestDTO)
    case createPhotoContent(capsuleId: Int, images: [Data])
    case deleteContent(contentId: Int)
}

extension CapsuleContentTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchCapsuleContents(let capsuleId):
            return "/api/time-capsule-content/\(capsuleId)/contents"
        case .createTextContent(let capsuleId, _),
             .createPhotoContent(let capsuleId, _):
            return "/api/time-capsule-content/\(capsuleId)"
        case .deleteContent(let contentId):
            return "/api/time-capsule-content/\(contentId)"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchCapsuleContents:
            return .get
        case .createTextContent, .createPhotoContent:
            return .post
        case .deleteContent:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchCapsuleContents:
            return .requestPlain

        case .createTextContent(_, let request):
            let jsonData = (try? JSONEncoder().encode(request)) ?? Data()
            let requestPart = MultipartFormData(
                provider: .data(jsonData),
                name: "request",
                mimeType: "application/json"
            )
            return .uploadMultipart([requestPart])

        case .createPhotoContent(_, let images):
            let parts = images.enumerated().map { index, data in
                MultipartFormData(
                    provider: .data(data),
                    name: "files",
                    fileName: "photo_\(index).jpg",
                    mimeType: "image/jpeg"
                )
            }
            return .uploadMultipart(parts)

        case .deleteContent:
            return .requestPlain
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .fetchCapsuleContents, .createTextContent, .createPhotoContent, .deleteContent:
            return true
        }
    }
}
