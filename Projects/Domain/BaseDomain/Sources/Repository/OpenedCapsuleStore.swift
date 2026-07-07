import Foundation

public protocol OpenedCapsuleStore {
    func isOpened(capsuleId: Int) -> Bool
    func markOpened(capsuleId: Int)
}
