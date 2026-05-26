import Foundation

public enum CapsuleContent {
    case text(id: Int, content: String)
    case photo(id: Int, imageUrls: [String])

    public var id: Int {
        switch self {
        case .text(let id, _): return id
        case .photo(let id, _): return id
        }
    }
}
