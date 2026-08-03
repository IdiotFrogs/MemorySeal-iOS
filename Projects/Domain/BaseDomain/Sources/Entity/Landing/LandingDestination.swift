import Foundation

public enum LandingDestination {
    case memberList(capsuleId: Int)
    case openCapsule(capsuleId: Int)
    case ticketDetail(capsuleId: Int)
    case invite(capsuleId: Int)
}
