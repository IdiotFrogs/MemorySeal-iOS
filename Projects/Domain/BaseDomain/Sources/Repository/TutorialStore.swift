import Foundation

public protocol TutorialStore {
    func isPending() -> Bool
    func markPending()
    func clearPending()
}
