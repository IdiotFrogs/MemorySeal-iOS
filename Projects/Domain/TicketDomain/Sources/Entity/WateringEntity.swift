import Foundation

public struct WateringEntity {
    public let totalDays: Int
    public let wateringCount: Int
    public let stage: Int
    public let days: [WateringDayEntity]
    public let currentPage: Int
    public let totalPages: Int
    public let totalElements: Int
    public let isLast: Bool

    public init(
        totalDays: Int,
        wateringCount: Int,
        stage: Int,
        days: [WateringDayEntity],
        currentPage: Int,
        totalPages: Int,
        totalElements: Int,
        isLast: Bool
    ) {
        self.totalDays = totalDays
        self.wateringCount = wateringCount
        self.stage = stage
        self.days = days
        self.currentPage = currentPage
        self.totalPages = totalPages
        self.totalElements = totalElements
        self.isLast = isLast
    }
}

public struct WateringDayEntity {
    public let wateredDate: Date?
    public let isWatered: Bool
    public let userId: Int?
    public let nickname: String?
    public let profileImageUrl: String?

    public init(
        wateredDate: Date?,
        isWatered: Bool,
        userId: Int?,
        nickname: String?,
        profileImageUrl: String?
    ) {
        self.wateredDate = wateredDate
        self.isWatered = isWatered
        self.userId = userId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
    }
}
