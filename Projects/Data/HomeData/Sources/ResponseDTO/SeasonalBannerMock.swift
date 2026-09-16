#if DEBUG
import Foundation

import BaseDomain

enum SeasonalBannerMock {
    static let entity: SeasonalBannerEntity = .init(
        content: "지난 여름 우리",
        season: "SUMMER",
        timeCapsuleId: 0,
        title: "티켓이름티켓이름티켓이름",
        imageUrl: nil
    )
}
#endif
