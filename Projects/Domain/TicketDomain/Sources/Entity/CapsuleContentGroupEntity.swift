import Foundation

public struct CapsuleContentGroupEntity {
    public let userId: Int
    public let nickname: String
    public let profileImageUrl: String
    public let contents: [CapsuleContent]

    public init(
        userId: Int,
        nickname: String,
        profileImageUrl: String,
        contents: [CapsuleContent]
    ) {
        self.userId = userId
        self.nickname = nickname
        self.profileImageUrl = profileImageUrl
        self.contents = contents
    }
}
