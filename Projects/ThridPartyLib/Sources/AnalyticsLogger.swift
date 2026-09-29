//
//  AnalyticsLogger.swift
//  ThridPartyLib
//
//  Created by 선민재 on 9/29/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation

import FirebaseAnalytics

public enum AnalyticsMessageType: String {
    case text
    case image
}

public enum AnalyticsEvent {
    case visitedScreen(screenName: String)
    case createTicket
    case addMessage(type: AnalyticsMessageType)
    case buriedTicket(createdDay: Int, buriedDay: Int)
    case wateringTicket(stage: Int)
    case openTicket(openedDay: Int)
    case visitOpenedTicket

    var name: String {
        switch self {
        case .visitedScreen: return "visited_screen"
        case .createTicket: return "create_ticket"
        case .addMessage: return "add_message"
        case .buriedTicket: return "buried_ticket"
        case .wateringTicket: return "watering_ticket"
        case .openTicket: return "open_ticket"
        case .visitOpenedTicket: return "visit_opened_ticket"
        }
    }

    var parameters: [String: Any]? {
        switch self {
        case .visitedScreen(let screenName):
            return ["screen_name": screenName]
        case .createTicket:
            return nil
        case .addMessage(let type):
            return ["type": type.rawValue]
        case .buriedTicket(let createdDay, let buriedDay):
            return ["created_day": createdDay, "buried_day": buriedDay]
        case .wateringTicket(let stage):
            return ["stage": stage]
        case .openTicket(let openedDay):
            return ["opened_day": openedDay]
        case .visitOpenedTicket:
            return nil
        }
    }
}

public enum AnalyticsLogger {
    public static func log(_ event: AnalyticsEvent) {
        Analytics.logEvent(event.name, parameters: event.parameters)
    }
}
