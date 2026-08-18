#if DEBUG
import Foundation
import Moya

public enum UITestStubResponse {
    public static let stubNetworkKey: String = "UITEST_STUB_NETWORK"

    public static var isStubNetworkEnabled: Bool {
        return ProcessInfo.processInfo.environment[stubNetworkKey] == "1"
    }

    private static let lock: NSLock = NSLock()
    private static var joinedCapsuleIds: Set<Int> = []

    public static func data(for target: TargetType) -> Data {
        let path = target.path

        switch path {
        case "/users/me":
            return userInfo
        case "/time-capsules/my":
            return myTimeCapsules
        default:
            break
        }

        guard let capsuleId = capsuleId(in: path) else { return Data() }

        if path.hasSuffix("/join") {
            markJoined(capsuleId: capsuleId)
            return Data()
        }

        if path.hasSuffix("/collaborators") {
            return collaborators
        }

        return ticketDetail(capsuleId: capsuleId)
    }
}

extension UITestStubResponse {
    private static func capsuleId(in path: String) -> Int? {
        let components = path.split(separator: "/")
        guard components.count >= 2, components[0] == "time-capsules" else { return nil }
        return Int(components[1])
    }

    private static func markJoined(capsuleId: Int) {
        lock.lock()
        joinedCapsuleIds.insert(capsuleId)
        lock.unlock()
    }

    private static func hasJoined(capsuleId: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        return joinedCapsuleIds.contains(capsuleId)
    }
}

extension UITestStubResponse {
    public static let joinedTicketTitle: String = "초대 수락 티켓"
    public static let notJoinedTicketTitle: String = "미참여 티켓"

    private static var userInfo: Data {
        return json(
            """
            {
                "id": 1,
                "nickname": "UITest",
                "profileImageUrl": "",
                "email": "uitest@memoryseal.io",
                "isOnboarding": true
            }
            """
        )
    }

    private static var myTimeCapsules: Data {
        return json(
            """
            [
                {
                    "timeCapsuleId": 1,
                    "title": "홈 티켓",
                    "openedAt": "2026-09-01",
                    "createdAt": "2026-08-01T00:00",
                    "timeCapsuleStatus": "BEFOREBURIED",
                    "role": "HOST",
                    "mainImageUrl": null,
                    "imageUrl": null
                }
            ]
            """
        )
    }

    private static func ticketDetail(capsuleId: Int) -> Data {
        let title = hasJoined(capsuleId: capsuleId) ? joinedTicketTitle : notJoinedTicketTitle

        return json(
            """
            {
                "title": "\(title)",
                "description": "UITest 티켓 설명",
                "createdAt": "2026-08-01T00:00",
                "buriedAt": null,
                "openedAt": null,
                "mainImageUrl": null,
                "timeCapsuleStatus": "BEFOREBURIED",
                "userRole": "CONTRIBUTOR",
                "myContentCount": 0,
                "myImageCount": 0
            }
            """
        )
    }

    private static var collaborators: Data {
        return json(
            """
            {
                "content": [
                    {
                        "userId": 1,
                        "nickname": "UITest",
                        "profileImageUrl": null,
                        "contributorRole": "HOST",
                        "isMe": true,
                        "userActiveStatus": true
                    }
                ],
                "last": true,
                "number": 0,
                "totalElements": 1,
                "totalPages": 1
            }
            """
        )
    }

    private static func json(_ string: String) -> Data {
        return Data(string.utf8)
    }
}
#endif
