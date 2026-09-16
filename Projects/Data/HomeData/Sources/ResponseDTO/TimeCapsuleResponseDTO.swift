import Foundation

import BaseDomain

struct TimeCapsulePageResponseDTO: Decodable {
    let content: [TimeCapsuleResponseDTO]
    let last: Bool?
    let number: Int?
    let totalElements: Int?
    let totalPages: Int?

    var toDomain: TimeCapsulePageEntity {
        return .init(
            timeCapsules: content.map { $0.toDomain },
            currentPage: number ?? 0,
            isLast: last ?? true,
            totalElements: totalElements ?? content.count
        )
    }
}

struct TimeCapsuleResponseDTO: Decodable {
    let timeCapsuleId: Int
    let title: String
    let openedAt: String?
    let createdAt: String?
    let timeCapsuleStatus: String
    let role: String
    let mainImageUrl: String?
    let imageUrl: String?
    let stage: Int?

    var toDomain: TimeCapsuleEntity {
        let openedAtDate = openedAt.flatMap { DateFormatter.serverDate.date(from: $0) }
        let createdAtDate = createdAt.flatMap {
            DateFormatter.serverDateTime.date(from: $0) ?? DateFormatter.serverDate.date(from: $0)
        }

        return .init(
            timeCapsuleId: timeCapsuleId,
            title: title,
            openedAt: openedAtDate,
            createdAt: createdAtDate,
            timeCapsuleStatus: TimeCapsuleStatus(rawValue: timeCapsuleStatus) ?? .beforeBuried,
            role: TimeCapsuleRole(rawValue: role) ?? .host,
            imageUrl: mainImageUrl ?? imageUrl,
            stage: stage ?? 0
        )
    }
}
