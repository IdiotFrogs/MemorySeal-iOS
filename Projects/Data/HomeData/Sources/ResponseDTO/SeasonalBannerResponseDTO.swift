import Foundation

import BaseDomain

struct SeasonalBannerResponseDTO: Decodable {
    let content: String
    let season: String
    let timeCapsuleId: Int

    var toDomain: SeasonalBannerEntity {
        return .init(
            content: content,
            season: season,
            timeCapsuleId: timeCapsuleId
        )
    }
}
