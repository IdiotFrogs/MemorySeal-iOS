import Foundation

public struct CreateContentRequestDTO: Encodable {
    let content: String

    public init(content: String) {
        self.content = content
    }
}
