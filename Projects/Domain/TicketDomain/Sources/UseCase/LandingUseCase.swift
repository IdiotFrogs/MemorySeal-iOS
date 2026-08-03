import Foundation

import BaseDomain

public protocol LandingUseCase {
    func resolve(_ destination: LandingDestination) async -> LandingResolution
}

public final class DefaultLandingUseCase: LandingUseCase {

    private let ticketDetailUseCase: TicketDetailUseCase
    private let joinCapsuleUseCase: JoinCapsuleUseCase

    public init(
        ticketDetailUseCase: TicketDetailUseCase,
        joinCapsuleUseCase: JoinCapsuleUseCase
    ) {
        self.ticketDetailUseCase = ticketDetailUseCase
        self.joinCapsuleUseCase = joinCapsuleUseCase
    }

    public func resolve(_ destination: LandingDestination) async -> LandingResolution {
        switch destination {
        case .memberList(let capsuleId):
            guard await isAccessible(capsuleId: capsuleId) else { return .none }
            return .memberList(capsuleId: capsuleId)

        case .ticketDetail(let capsuleId):
            guard await isAccessible(capsuleId: capsuleId) else { return .none }
            return .ticketDetail(capsuleId: capsuleId)

        case .openCapsule(let capsuleId):
            guard let detail = try? await ticketDetailUseCase.fetchDetail(capsuleId: capsuleId),
                  detail.timeCapsuleStatus == .opened
            else {
                return .none
            }
            return .openCapsule(capsuleId: capsuleId)

        case .invite(let capsuleId):
            if (try? await joinCapsuleUseCase.join(capsuleId: capsuleId)) != nil {
                return .ticketDetail(capsuleId: capsuleId)
            }
            guard await isAccessible(capsuleId: capsuleId) else { return .none }
            return .ticketDetail(capsuleId: capsuleId)
        }
    }

    private func isAccessible(capsuleId: Int) async -> Bool {
        return (try? await ticketDetailUseCase.fetchDetail(capsuleId: capsuleId)) != nil
    }
}
