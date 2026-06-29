import Foundation

public struct CollaboratorPageEntity {
    public let collaborators: [CollaboratorEntity]
    public let currentPage: Int
    public let isLast: Bool
    public let totalElements: Int

    public init(
        collaborators: [CollaboratorEntity],
        currentPage: Int,
        isLast: Bool,
        totalElements: Int
    ) {
        self.collaborators = collaborators
        self.currentPage = currentPage
        self.isLast = isLast
        self.totalElements = totalElements
    }
}
