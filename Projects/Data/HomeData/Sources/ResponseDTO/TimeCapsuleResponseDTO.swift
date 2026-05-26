import Foundation

import BaseDomain

struct TimeCapsuleResponseDTO: Decodable {
    let timeCapsuleId: Int
    let title: String
    let openedAt: String?
    let timeCapsuleStatus: String
    let role: String
    let imageUrl: String?

    var toDomain: TimeCapsuleEntity {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let date = openedAt.flatMap { dateFormatter.date(from: $0) }

        return .init(
            timeCapsuleId: timeCapsuleId,
            title: title,
            openedAt: date,
            timeCapsuleStatus: TimeCapsuleStatus(rawValue: timeCapsuleStatus) ?? .beforeBuried,
            role: TimeCapsuleRole(rawValue: role) ?? .host,
            imageUrl: imageUrl
        )
    }
}
