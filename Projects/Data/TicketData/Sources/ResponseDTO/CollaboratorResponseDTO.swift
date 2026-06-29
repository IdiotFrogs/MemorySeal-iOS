import Foundation

import BaseDomain
import TicketDomain

struct CollaboratorListResponseDTO: Decodable {
    let content: [CollaboratorResponseDTO]
    let last: Bool?
    let number: Int?
    let totalElements: Int?
    let totalPages: Int?

    var toDomain: CollaboratorPageEntity {
        return .init(
            collaborators: content.map { $0.toDomain },
            currentPage: number ?? 0,
            isLast: last ?? true,
            totalElements: totalElements ?? content.count
        )
    }
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
            role: TimeCapsuleRole(rawValue: contributorRole) ?? .contributor,
            isMe: isMe
        )
    }
}
