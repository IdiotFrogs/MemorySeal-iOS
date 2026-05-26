import Foundation

public protocol AddMemberUseCase {
    func inviteToTimeCapsule(capsuleId: Int) async throws -> String
}

public final class DefaultAddMemberUseCase: AddMemberUseCase {
    private let addMemberRepository: AddMemberRepository

    public init(addMemberRepository: AddMemberRepository) {
        self.addMemberRepository = addMemberRepository
    }

    public func inviteToTimeCapsule(capsuleId: Int) async throws -> String {
        return try await addMemberRepository.inviteToTimeCapsule(capsuleId: capsuleId)
    }
}
