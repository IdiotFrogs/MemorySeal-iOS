import Foundation

import MemoryDomain

struct CollaboratorResponseDTO: Decodable {
    let userId: Int
    let nickname: String
    let profileImageUrl: String?
    let contributorRole: String
    let isMe: Bool
    let userActiveStatus: Bool?

    var toDomain: CollaboratorEntity {
        return .init(
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl,
            role: CollaboratorRole(rawValue: contributorRole) ?? .contributor,
            isMe: isMe
        )
    }
}
