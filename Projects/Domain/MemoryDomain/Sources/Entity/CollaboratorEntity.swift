import Foundation

public enum CollaboratorRole: String {
    case host = "HOST"
    case contributor = "CONTRIBUTOR"
}

public struct CollaboratorEntity {
    public let userId: Int
    public let nickname: String
    public let profileImageUrl: String?
    public let role: CollaboratorRole
    public let isMe: Bool

    public init(
        userId: Int,
        nickname: String,
        profileImageUrl: String?,
        role: CollaboratorRole,
        isMe: Bool
    ) {
        self.userId = userId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.role = role
        self.isMe = isMe
    }
}
