import Foundation

import BaseDomain

struct UnopenedTimeCapsuleResponseDTO: Decodable {
    let timeCapsuleId: Int
    let title: String
    let openedAt: String?
    let mainImageUrl: String?

    var toDomain: TimeCapsuleEntity {
        return .init(
            timeCapsuleId: timeCapsuleId,
            title: title,
            openedAt: openedAt.flatMap { DateFormatter.serverDate.date(from: $0) },
            createdAt: nil,
            timeCapsuleStatus: .opened,
            role: .host,
            imageUrl: mainImageUrl,
            stage: 0
        )
    }
}
