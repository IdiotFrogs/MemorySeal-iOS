import Foundation

public protocol ManageTicketUseCase {
    func deleteTimeCapsule(capsuleId: Int) async throws
    func leaveTimeCapsule(capsuleId: Int) async throws
}

public final class DefaultManageTicketUseCase: ManageTicketUseCase {
    private let manageTicketRepository: ManageTicketRepository

    public init(manageTicketRepository: ManageTicketRepository) {
        self.manageTicketRepository = manageTicketRepository
    }

    public func deleteTimeCapsule(capsuleId: Int) async throws {
        try await manageTicketRepository.deleteTimeCapsule(capsuleId: capsuleId)
    }

    public func leaveTimeCapsule(capsuleId: Int) async throws {
        try await manageTicketRepository.leaveTimeCapsule(capsuleId: capsuleId)
    }
}
