import Foundation

import BaseDomain
import TicketDomain

struct WateringResponseDTO: Decodable {
    let totalDays: Int?
    let wateringCount: Int?
    let stage: Int?
    let waterings: WateringPageResponseDTO?

    var toDomain: WateringEntity {
        return .init(
            totalDays: totalDays ?? 0,
            wateringCount: wateringCount ?? 0,
            stage: stage ?? 0,
            days: waterings?.content.map { $0.toDomain } ?? [],
            currentPage: waterings?.number ?? 0,
            totalPages: waterings?.totalPages ?? 0,
            totalElements: waterings?.totalElements ?? 0,
            isLast: waterings?.last ?? true
        )
    }
}

struct WateringPageResponseDTO: Decodable {
    let content: [WateringDayResponseDTO]
    let totalPages: Int?
    let totalElements: Int?
    let number: Int?
    let last: Bool?
}

struct WateringDayResponseDTO: Decodable {
    let wateredDate: String?
    let isWatered: Bool?
    let userId: Int?
    let nickname: String?
    let profileImageUrl: String?

    var toDomain: WateringDayEntity {
        return .init(
            wateredDate: wateredDate.flatMap { DateFormatter.serverDate.date(from: $0) },
            isWatered: isWatered ?? false,
            userId: userId,
            nickname: nickname,
            profileImageUrl: profileImageUrl
        )
    }
}
