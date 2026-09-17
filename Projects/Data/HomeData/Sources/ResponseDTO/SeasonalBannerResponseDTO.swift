import Foundation

import BaseDomain

struct SeasonalBannerResponseDTO: Decodable {
    let content: String
    let season: String
    let capsuleId: Int
    let title: String?
    let mainImageUrl: String?
    let imageUrl: String?

    var toDomain: SeasonalBannerEntity {
        return .init(
            content: content,
            season: season,
            timeCapsuleId: capsuleId,
            title: title,
            imageUrl: mainImageUrl ?? imageUrl
        )
    }
}
