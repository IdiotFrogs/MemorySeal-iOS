import Foundation

public enum LandingResolution {
    case memberList(capsuleId: Int)
    case openCapsule(capsuleId: Int)
    case ticketDetail(capsuleId: Int)
    case none
}
