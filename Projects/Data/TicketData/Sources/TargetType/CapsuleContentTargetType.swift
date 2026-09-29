import Foundation
import Moya

import BaseData

public enum CapsuleContentTargetType {
    case fetchCapsuleContents(capsuleId: Int, page: Int, size: Int)
    case fetchMyCapsuleContents(capsuleId: Int)
    case createTextContent(capsuleId: Int, content: String)
    case createPhotoContent(capsuleId: Int, images: [Data])
    case updateTextContent(contentId: Int, content: String)
    case deleteContents(contentIds: [Int], fileIds: [Int])
}

extension CapsuleContentTargetType: BaseTargetType {
    public var path: String {
        switch self {
        case .fetchCapsuleContents(let capsuleId, _, _):
            return "/api/time-capsule-content/\(capsuleId)/contents"
        case .fetchMyCapsuleContents(let capsuleId):
            return "/api/time-capsule-content/\(capsuleId)/my-contents"
        case .createTextContent(let capsuleId, _),
             .createPhotoContent(let capsuleId, _):
            return "/api/time-capsule-content/\(capsuleId)"
        case .updateTextContent(let contentId, _):
            return "/api/time-capsule-content/\(contentId)"
        case .deleteContents:
            return "/api/time-capsule-content"
        }
    }

    public var method: Moya.Method {
        switch self {
        case .fetchCapsuleContents, .fetchMyCapsuleContents:
            return .get
        case .createTextContent, .createPhotoContent:
            return .post
        case .updateTextContent:
            return .put
        case .deleteContents:
            return .delete
        }
    }

    public var task: Moya.Task {
        switch self {
        case .fetchCapsuleContents(_, let page, let size):
            return .requestParameters(
                parameters: ["page": page, "size": size],
                encoding: URLEncoding.queryString
            )

        case .fetchMyCapsuleContents:
            return .requestPlain

        case .createTextContent(_, let content):
            let contentPart = MultipartFormData(
                provider: .data(content.data(using: .utf8) ?? Data()),
                name: "content",
                mimeType: "text/plain"
            )
            return .uploadMultipart([contentPart])

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

        case .updateTextContent(_, let content):
            return .requestParameters(
                parameters: ["content": content],
                encoding: URLEncoding.queryString
            )

        case .deleteContents(let contentIds, let fileIds):
            var parameters: [String: Any] = ["contentIds": contentIds]
            if !fileIds.isEmpty {
                parameters["fileIds"] = fileIds
            }
            return .requestParameters(
                parameters: parameters,
                encoding: URLEncoding(
                    destination: .queryString,
                    arrayEncoding: .noBrackets,
                    boolEncoding: .numeric
                )
            )
        }
    }

    public var headers: [String: String]? {
        return nil
    }

    public var isNeededAccessToken: Bool {
        switch self {
        case .fetchCapsuleContents, .fetchMyCapsuleContents, .createTextContent, .createPhotoContent, .updateTextContent, .deleteContents:
            return true
        }
    }
}
