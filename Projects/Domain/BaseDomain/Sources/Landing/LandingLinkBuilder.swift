import Foundation

public enum LandingLinkBuilder {
    public static func inviteLink(code: String, capsuleId: Int) -> URL? {
        var components = URLComponents()
        components.scheme = LandingLinkConfiguration.scheme
        components.host = LandingLinkConfiguration.host
        components.path = "/"
        components.queryItems = [
            URLQueryItem(name: LandingLinkConfiguration.codeKey, value: code),
            URLQueryItem(name: LandingLinkConfiguration.actionKey, value: LandingAction.invite.rawValue),
            URLQueryItem(name: LandingLinkConfiguration.capsuleIdKey, value: String(capsuleId))
        ]

        return components.url
    }
}
