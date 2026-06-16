import UIKit

import DesignSystem

// MARK: - MemoryParticipant

public struct MemoryParticipant {
    public let id: Int
    public let name: String
    public let profileImage: UIImage?

    public init(id: Int, name: String, profileImage: UIImage? = nil) {
        self.id = id
        self.name = name
        self.profileImage = profileImage
    }

    public var displayImage: UIImage? {
        profileImage ?? DesignSystemAsset.ImageAssets.userDefaultProfileImage.image
    }
}

// MARK: - MemoryMessageContent

public enum MemoryMessageContent {
    case text(String)
    case photo(count: Int)
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
    public let messages: [MemoryMessage]

    public init(participant: MemoryParticipant, messages: [MemoryMessage]) {
        self.participant = participant
        self.messages = messages
    }
}

// MARK: - Mock

public enum MemoryMessageMock {
    private static let sampleText = "별거 아닌 대화, 별거 아닌 하루가 이렇게 기억에 남을 줄이야. 고마워, 다음에도 함께하자."

    public static let profileImage: UIImage? = UIImage(
        named: "Profile",
        in: TicketPresentationResources.bundle,
        compatibleWith: nil
    )

    public static func conversations() -> [MemoryConversation] {
        let participants = [
            MemoryParticipant(id: 1, name: "파란 바나나", profileImage: profileImage),
            MemoryParticipant(id: 2, name: "검정 복숭아", profileImage: profileImage),
            MemoryParticipant(id: 3, name: "별 모양 파인애플", profileImage: profileImage),
            MemoryParticipant(id: 4, name: "나", profileImage: profileImage),
            MemoryParticipant(id: 5, name: "초코 체리", profileImage: profileImage)
        ]

        return participants.map { participant in
            let isMine = participant.name == "나"
            return MemoryConversation(
                participant: participant,
                messages: [
                    MemoryMessage(content: .text(sampleText), isMine: isMine),
                    MemoryMessage(content: .text(sampleText), isMine: isMine),
                    MemoryMessage(content: .photo(count: 2), isMine: isMine),
                    MemoryMessage(content: .text(sampleText), isMine: isMine)
                ]
            )
        }
    }
}
