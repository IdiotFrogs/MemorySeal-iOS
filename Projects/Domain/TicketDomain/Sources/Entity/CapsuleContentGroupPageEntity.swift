import Foundation

public struct CapsuleContentGroupPageEntity {
    public let groups: [CapsuleContentGroupEntity]
    public let currentPage: Int
    public let isLast: Bool
    public let totalElements: Int

    public init(
        groups: [CapsuleContentGroupEntity],
        currentPage: Int,
        isLast: Bool,
        totalElements: Int
    ) {
        self.groups = groups
        self.currentPage = currentPage
        self.isLast = isLast
        self.totalElements = totalElements
    }
}
