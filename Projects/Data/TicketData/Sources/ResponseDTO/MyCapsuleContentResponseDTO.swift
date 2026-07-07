import Foundation

import TicketDomain

struct MyCapsuleContentResponseDTO: Decodable {
    let contentId: Int
    let content: String?
    let attachedFiles: [MyContentAttachedFileDTO]?

    var toDomain: CapsuleContent {
        if let content = content, !content.isEmpty {
            return .text(id: contentId, content: content)
        } else {
            return .photo(id: contentId, imageUrls: (attachedFiles ?? []).map { $0.fileUrl })
        }
    }
}

struct MyContentAttachedFileDTO: Decodable {
    let id: Int
    let fileUrl: String
    let fileType: String
}
