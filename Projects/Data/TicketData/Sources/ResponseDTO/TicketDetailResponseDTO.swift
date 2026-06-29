import Foundation

import BaseDomain
import TicketDomain

struct TicketDetailResponseDTO: Decodable {
    let title: String
    let description: String
    let createdAt: String
    let buriedAt: String?
    let openedAt: String?
    let mainImageUrl: String?
    let timeCapsuleStatus: String
    let userRole: String
    let myContentCount: Int
    let myImageCount: Int

    var toDomain: TicketDetailEntity {
        return .init(
            title: title,
            description: description,
            createdAt: DateFormatter.serverDateTime.date(from: createdAt) ?? Date(),
            buriedAt: buriedAt.flatMap { DateFormatter.serverDateTime.date(from: $0) },
            openedAt: openedAt.flatMap { DateFormatter.serverDateTime.date(from: $0) },
            mainImageUrl: mainImageUrl,
            timeCapsuleStatus: TimeCapsuleStatus(rawValue: timeCapsuleStatus) ?? .beforeBuried,
            userRole: TimeCapsuleRole(rawValue: userRole) ?? .contributor,
            myContentCount: myContentCount,
            myImageCount: myImageCount
        )
    }
}
