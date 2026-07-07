import UIKit

import DesignSystem

// MARK: - MemoryParticipant

public struct MemoryParticipant {
    public let id: Int
    public let name: String
    public let profileImageUrl: String?

    public init(id: Int, name: String, profileImageUrl: String? = nil) {
        self.id = id
        self.name = name
        self.profileImageUrl = profileImageUrl
    }
}

// MARK: - MemoryMessageContent

public enum MemoryMessageContent {
    case text(String)
    case photo(imageUrls: [String])
}

// MARK: - MemoryMessage

public struct MemoryMessage {
    public let content: MemoryMessageContent
    public let isMine: Bool

    public init(content: MemoryMessageContent, isMine: Bool) {
        self.content = content
        self.isMine = isMine
    }
}

// MARK: - MemoryConversation

public struct MemoryConversation {
    public let participant: MemoryParticipant
    public let isMine: Bool
    public let messages: [MemoryMessage]

    public init(participant: MemoryParticipant, isMine: Bool, messages: [MemoryMessage]) {
        self.participant = participant
        self.isMine = isMine
        self.messages = messages
    }
}

// MARK: - MemoryGroup

struct MemoryGroup {
    let participant: MemoryParticipant
    let isMine: Bool
    let contents: [MemoryMessageContent]
}
