import Foundation

import MemoryDomain

struct CapsuleContentGroupResponseDTO: Decodable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String
    let capsuleContents: [CapsuleContentResponseDTO]

    var toDomain: CapsuleContentGroupEntity {
        return .init(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            contents: capsuleContents.map { $0.toDomain }
        )
    }
}

struct CapsuleContentResponseDTO: Decodable {
    let contentId: Int
    let content: String?
    let attachedFileUrls: [String]?

    var toDomain: CapsuleContent {
        if let content = content, !content.isEmpty {
            return .text(id: contentId, content: content)
        } else {
            return .photo(id: contentId, imageUrls: attachedFileUrls ?? [])
        }
    }
}
