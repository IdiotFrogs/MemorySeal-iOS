#if DEBUG
import Foundation

import BaseData
import BaseDomain

enum UITestLaunchSupport {
    private static let landingPayloadKey: String = "UITEST_LANDING_PAYLOAD"
    private static let stubAccessToken: String = "uitest-access-token"

    static var isEnabled: Bool {
        return UITestStubResponse.isStubNetworkEnabled
    }

    static func prepareIfNeeded() {
        guard isEnabled else { return }
        DefaultKeyChainStorage().add(value: stubAccessToken, forKey: .accessToken)
    }

    static func landingDestination() -> LandingDestination? {
        guard isEnabled,
              let payload = ProcessInfo.processInfo.environment[landingPayloadKey],
              let object = try? JSONSerialization.jsonObject(with: Data(payload.utf8)),
              let userInfo = object as? [AnyHashable: Any]
        else {
            return nil
        }

        return LandingLinkParser.parse(userInfo: userInfo)
    }
}
#endif
