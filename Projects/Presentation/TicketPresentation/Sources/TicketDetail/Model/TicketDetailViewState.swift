import Foundation

public enum TicketDetailSection: CaseIterable {
    case ticketImage
    case ticketDescription
    case buryTicket
    case myMessages
    case members
}

public struct TicketDetailViewState {
    public let sections: [TicketDetailSection]
    public let isOpened: Bool

    public init(sections: [TicketDetailSection], isOpened: Bool) {
        self.sections = sections
        self.isOpened = isOpened
    }

    public static let initial: TicketDetailViewState = .init(
        sections: TicketDetailSection.allCases,
        isOpened: false
    )
}
