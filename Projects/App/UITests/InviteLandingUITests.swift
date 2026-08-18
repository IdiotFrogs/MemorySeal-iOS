import XCTest

final class InviteLandingUITests: XCTestCase {

    private enum Identifier {
        static let ticketDetailView: String = "TicketDetailView"
    }

    private enum TicketTitle {
        static let joined: String = "초대 수락 티켓"
        static let notJoined: String = "미참여 티켓"
    }

    private enum Timeout {
        static let landing: TimeInterval = 20
        static let content: TimeInterval = 5
    }

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func test_invite_페이로드로_실행하면_join_후_티켓_상세로_진입한다() {
        let app = launchApp(landingPayload: payload(action: "invite", capsuleId: 77))

        XCTAssertTrue(
            app.otherElements[Identifier.ticketDetailView].waitForExistence(timeout: Timeout.landing)
        )
        XCTAssertTrue(
            app.staticTexts[TicketTitle.joined].waitForExistence(timeout: Timeout.content)
        )
    }

    func test_detail_페이로드로_실행하면_join_없이_티켓_상세로_진입한다() {
        let app = launchApp(landingPayload: payload(action: "detail", capsuleId: 77))

        XCTAssertTrue(
            app.otherElements[Identifier.ticketDetailView].waitForExistence(timeout: Timeout.landing)
        )
        XCTAssertTrue(
            app.staticTexts[TicketTitle.notJoined].waitForExistence(timeout: Timeout.content)
        )
    }

    func test_페이로드가_없으면_홈에_머무른다() {
        let app = launchApp(landingPayload: nil)

        XCTAssertTrue(app.staticTexts["타임 티켓"].waitForExistence(timeout: Timeout.landing))
        XCTAssertFalse(app.otherElements[Identifier.ticketDetailView].exists)
    }

    func test_알_수_없는_액션이면_홈에_머무른다() {
        let app = launchApp(landingPayload: payload(action: "unknown", capsuleId: 77))

        XCTAssertTrue(app.staticTexts["타임 티켓"].waitForExistence(timeout: Timeout.landing))
        XCTAssertFalse(app.otherElements[Identifier.ticketDetailView].exists)
    }
}

extension InviteLandingUITests {
    private func launchApp(landingPayload: String?) -> XCUIApplication {
        let app = XCUIApplication()

        var environment: [String: String] = ["UITEST_STUB_NETWORK": "1"]
        if let landingPayload {
            environment["UITEST_LANDING_PAYLOAD"] = landingPayload
        }
        app.launchEnvironment = environment

        app.launch()
        return app
    }

    private func payload(action: String, capsuleId: Int) -> String {
        return #"{"action":"\#(action)","capsuleId":"\#(capsuleId)"}"#
    }
}
