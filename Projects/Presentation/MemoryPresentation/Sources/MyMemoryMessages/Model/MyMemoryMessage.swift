import Foundation

// MARK: - MyMemoryMessageType

public enum MyMemoryMessageType {
    case text
    case photo
}

// MARK: - MyMemoryMessage

public struct MyMemoryMessage {
    public let id: UUID
    public let type: MyMemoryMessageType
    public let textContent: String?
    public let imageData: Data?
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        type: MyMemoryMessageType,
        textContent: String? = nil,
        imageData: Data? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.type = type
        self.textContent = textContent
        self.imageData = imageData
        self.createdAt = createdAt
    }
}
