import Foundation

public protocol ManageTicketUseCase {
    func leaveTimeCapsule(capsuleId: Int) async throws
}

public final class DefaultManageTicketUseCase: ManageTicketUseCase {
    private let manageTicketRepository: ManageTicketRepository

    public init(manageTicketRepository: ManageTicketRepository) {
        self.manageTicketRepository = manageTicketRepository
    }

    public func leaveTimeCapsule(capsuleId: Int) async throws {
        try await manageTicketRepository.leaveTimeCapsule(capsuleId: capsuleId)
    }
}
