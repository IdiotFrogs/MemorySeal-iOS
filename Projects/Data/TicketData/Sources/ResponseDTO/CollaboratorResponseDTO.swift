import Foundation

import TicketDomain

struct CollaboratorListResponseDTO: Decodable {
    let content: [CollaboratorResponseDTO]
    let last: Bool?
    let number: Int?
    let totalElements: Int?
    let totalPages: Int?
}

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
