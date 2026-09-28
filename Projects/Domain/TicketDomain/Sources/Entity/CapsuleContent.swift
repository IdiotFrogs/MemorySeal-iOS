import Foundation

public struct CapsuleContentFile {
    public let id: Int?
    public let url: String

    public init(id: Int?, url: String) {
        self.id = id
        self.url = url
    }
}

public enum CapsuleContent {
    case text(id: Int, content: String)
    case photo(id: Int, files: [CapsuleContentFile])

    public var id: Int {
        switch self {
        case .text(let id, _): return id
        case .photo(let id, _): return id
        }
    }

    public var imageUrls: [String] {
        switch self {
        case .text: return []
        case .photo(_, let files): return files.map { $0.url }
        }
    }
}
