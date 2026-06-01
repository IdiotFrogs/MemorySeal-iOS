import Foundation

import BaseDomain

struct TimeCapsuleResponseDTO: Decodable {
    let timeCapsuleId: Int
    let title: String
    let openedAt: String?
    let createdAt: String?
    let timeCapsuleStatus: String
    let role: String
    let imageUrl: String?

    var toDomain: TimeCapsuleEntity {
        let openedAtDate = openedAt.flatMap { DateFormatter.serverDateTime.date(from: $0) }
        let createdAtDate = createdAt.flatMap { DateFormatter.serverDateTime.date(from: $0) }

        return .init(
            timeCapsuleId: timeCapsuleId,
            title: title,
            openedAt: openedAtDate,
            createdAt: createdAtDate,
            timeCapsuleStatus: TimeCapsuleStatus(rawValue: timeCapsuleStatus) ?? .beforeBuried,
            role: TimeCapsuleRole(rawValue: role) ?? .host,
            imageUrl: imageUrl
        )
    }
}
