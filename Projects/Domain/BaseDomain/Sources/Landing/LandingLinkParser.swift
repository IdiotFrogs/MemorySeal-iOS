import Foundation

public enum LandingLinkParser {

    public static func parse(url: URL) -> LandingDestination? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              components.host == LandingLinkConfiguration.host,
              let queryItems = components.queryItems
        else {
            return nil
        }

        let action = queryItems.first { $0.name == LandingLinkConfiguration.actionKey }?.value
        let capsuleId = queryItems.first { $0.name == LandingLinkConfiguration.capsuleIdKey }?.value

        return makeDestination(action: action, capsuleId: capsuleId)
    }

    public static func parse(userInfo: [AnyHashable: Any]) -> LandingDestination? {
        let action = stringValue(of: userInfo[LandingLinkConfiguration.actionKey])
        let capsuleId = stringValue(of: userInfo[LandingLinkConfiguration.capsuleIdKey])

        return makeDestination(action: action, capsuleId: capsuleId)
    }

    private static func makeDestination(action: String?, capsuleId: String?) -> LandingDestination? {
        guard let rawAction = action?.trimmingCharacters(in: .whitespaces).lowercased(),
              let landingAction = LandingAction(rawValue: rawAction),
              let capsuleId = capsuleId.flatMap({ Int($0.trimmingCharacters(in: .whitespaces)) })
        else {
            return nil
        }

        switch landingAction {
        case .member:
            return .memberList(capsuleId: capsuleId)
        case .open:
            return .openCapsule(capsuleId: capsuleId)
        case .detail:
            return .ticketDetail(capsuleId: capsuleId)
        case .invite:
            return .invite(capsuleId: capsuleId)
        }
    }

    private static func stringValue(of value: Any?) -> String? {
        switch value {
        case let string as String:
            return string
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }
}
