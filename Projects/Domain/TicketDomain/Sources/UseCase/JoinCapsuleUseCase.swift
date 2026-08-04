import Foundation

public protocol JoinCapsuleUseCase {
    func join(capsuleId: Int) async throws
}

public final class DefaultJoinCapsuleUseCase: JoinCapsuleUseCase {

    private let joinCapsuleRepository: JoinCapsuleRepository

    public init(joinCapsuleRepository: JoinCapsuleRepository) {
        self.joinCapsuleRepository = joinCapsuleRepository
    }

    public func join(capsuleId: Int) async throws {
        return try await joinCapsuleRepository.join(capsuleId: capsuleId)
    }
}
