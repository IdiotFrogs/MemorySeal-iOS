import Foundation

public struct InviteShareContent {
    public let title: String
    public let message: String
    public let link: URL
    public let thumbnailUrl: URL?

    public init(
        title: String,
        message: String,
        link: URL,
        thumbnailUrl: URL?
    ) {
        self.title = title
        self.message = message
        self.link = link
        self.thumbnailUrl = thumbnailUrl
    }
}
