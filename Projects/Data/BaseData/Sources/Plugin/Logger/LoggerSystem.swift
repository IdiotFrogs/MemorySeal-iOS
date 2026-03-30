//
//  LoggerSystem.swift
//  BaseData
//
//  Created by 선민재 on 3/30/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import os

public enum LoggerLevel: String, CaseIterable {
    case info = "info"
    case debug = "debug"
    case warning = "warning"
    case error = "error"
    case critical = "critical"
    
    var emoji: String {
        switch self {
        case .info: return "ℹ️"
        case .debug: return "🔍"
        case .warning: return "⚠️"
        case .error: return "❌"
        case .critical: return "🚨"
        }
    }
}

public struct LoggerSystem {
    let category: String
    let subsystem: String
    let isEnabled: Bool
    let allowedLevels: Set<LoggerLevel>?
    let useOSLog: Bool
    let useConsole: Bool
    let showMetadata: Bool // 메타데이터 표시 여부를 제어하는 Bool 타입 프로퍼티 (기본값: `true`)
    let showSourceInfo: Bool // 소스 정보(파일명, 라인, 함수명) 표시 여부를 제어하는 Bool 타입 프로퍼티 (기본값: `true`)
    
    @available(iOS 14.0, *)
    private var osLogger: Logger {
        Logger(subsystem: subsystem, category: category)
    }
    
    public init(
        category: String,
        subsystem: String = "com.photocard.masterDev",
        isEnabled: Bool = true,
        allowedLevels: Set<LoggerLevel>? = nil,
        useOSLog: Bool = true,
        useConsole: Bool = true,
        showMetadata: Bool = true,
        showSourceInfo: Bool = true
    ) {
        self.category = category
        self.subsystem = subsystem
        self.isEnabled = isEnabled
        self.allowedLevels = allowedLevels
        self.useOSLog = useOSLog
        self.useConsole = useConsole
        self.showMetadata = showMetadata // 초기화 시 설정 가능
        self.showSourceInfo = showSourceInfo // 초기화 시 설정 가능
    }

    private func log(
        _ level: LoggerLevel,
        message: String,
        metadata: [String: Any] = [:],
        file: String = #file,
        function: String = #function,
        line: UInt = #line
    ) {
        guard isEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.logTimestamp.string(from: Date())
        let levelEmoji = level.emoji
        
        // 소스 정보 포맷 생성
        let sourceInfo = showSourceInfo ? " [\(fileName)#\(line) \(function)]" : ""
        
#if DEBUG
        // OS Log 전송
        if #available(iOS 14.0, *),
           useOSLog
        {
            let osMessage = "[\(timestamp) \(levelEmoji) \(fileName)#\(line) \(function)] \(message)"
            
            switch level {
            case .info:
                osLogger.info("\(osMessage, privacy: .public)")
            case .debug:
                osLogger.debug("\(osMessage, privacy: .public)")
            case .warning:
                osLogger.warning("\(osMessage, privacy: .public)")
            case .error:
                osLogger.error("\(osMessage, privacy: .public)")
            case .critical:
                osLogger.fault("\(osMessage, privacy: .public)")
            }
        }
#endif
        
        // 허용된 레벨만큼 콘솔 출력되도록
        if let allowed = allowedLevels, allowed.contains(level) == false {
            return
        }
        
        // 콘솔 출력
#if DEBUG
        if  useConsole {
            print("----------------------------------------------------------------------------------------------------------")
            print("[\(timestamp)] \(levelEmoji) \(level.rawValue.uppercased()) [\(category)]:\(sourceInfo) \(message)")
            
            // 메타데이터가 있으면 별도로 출력
            if !metadata.isEmpty && showMetadata {
                print("📋 Metadata:")
                for (key, value) in metadata.sorted(by: { $0.key < $1.key }) {
                    print("  • \(key): \(value)")
                }
            }
        }
#endif
    }
    
    public func info(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        log(.info, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func debug(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        log(.debug, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func warning(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        log(.warning, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func error(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        log(.error, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
    public func critical(_ message: String, metadata: [String: Any] = [:], file: String = #file, function: String = #function, line: UInt = #line) {
        log(.critical, message: message, metadata: metadata, file: file, function: function, line: line)
    }
    
}

// MARK: - DateFormatter Extension
extension DateFormatter {
    static let logTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        return formatter
    }()
}
