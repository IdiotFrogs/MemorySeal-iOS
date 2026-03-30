//
//  MoyaLoggerPlugin.swift
//  BaseData
//
//  Created by 선민재 on 3/30/26.
//  Copyright © 2026 MemorySeal. All rights reserved.
//

import Foundation
import Moya

final class MoyaLoggerPlugin: PluginType {
    
    private let logger: LoggerSystem
    
    init(logger: LoggerSystem? = nil) {
        self.logger = logger ?? LoggerSystem(
            category: "Network",
            useOSLog: true,
            useConsole: true,
            showMetadata: true,
            showSourceInfo: false
        )
    }
    
    func willSend(_ request: Moya.RequestType, target: TargetType) {
        let url = request.request?.url?.absoluteString ?? "Unknown URL"
        let httpMethod = request.request?.httpMethod ?? "Unknown Method"
        let headers = request.request?.allHTTPHeaderFields ?? [:]
        
        var metaData: [String: Any] = [
            "🎯 target": String(describing: target),
            "🔧 method": httpMethod,
            "🌐 url": url
            /// 헤더 정보 주석 처리
//            "📝 requestHeaders": headers
        ]
        
        // 요청 바디가 있는 경우 로깅
        if let httpBody = request.request?.httpBody,
           let bodyString = String(data: httpBody, encoding: .utf8) {
            metaData["requestBody"] = bodyString
        }
        
        logger.debug("🚀 네트워크 요청 시작 \n🌐 url: \(url)", metadata: metaData)
    }
    
    func didReceive(_ result: Result<Response, MoyaError>, target: TargetType) {
        switch result {
        case let .success(response):
            onSuceed(response, target: target)
        case let .failure(error):
            onFail(error, target: target)
        }
    }
    
    func onSuceed(_ response: Response, target: TargetType) {
        let url = response.request?.url?.absoluteString ?? "Unknown URL"
        let responseHeaders = response.response?.allHeaderFields ?? [:]
        let isSuccess = 200..<300 ~= response.statusCode
        
        var metaData: [String: Any] = [
            "🎯 target": String(describing: target),
            "🌐 url": url,
            "📊 statusCode": response.statusCode
            /// 헤더 정보 주석 처리
//            "📝 responseHeaders": responseHeaders
        ]
        
        // 응답 데이터 출력
        if let jsonObject = try? JSONSerialization.jsonObject(with: response.data, options: []) {
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                let finalJson = jsonString.count > 1000 ?
                String(jsonString.prefix(1000)) + "\n..." : jsonString
                metaData["responseBody"] = finalJson
            } else {
                metaData["responseBody"] = jsonObject
            }
        } else if let responseString = String(data: response.data, encoding: .utf8) {
            let truncatedString = responseString.count > 500 ?
            String(responseString.prefix(500)) + "..." : responseString
            metaData["responseBody"] = truncatedString
        } else {
            let dataDescription = response.data.count > 100 ?
            "Binary data (\(response.data.count) bytes)" : response.data.description
            metaData["responseBody"] = dataDescription
        }
        
        if isSuccess {
            logger.info("✅ 네트워크 요청 성공\n🌐 url: \(url)", metadata: metaData)
        } else {
            logger.warning("⚠️ 네트워크 요청 완료 (비정상 상태)\n🌐 url: \(url)", metadata: metaData)
        }
    }
    
    func onFail(_ error: MoyaError, target: TargetType) {
        let url = error.response?.request?.url?.absoluteString ?? "Unknown URL"
        let errorHeaders = error.response?.response?.allHeaderFields ?? [:]
        let statusCode = error.response?.statusCode
        
        var metaData: [String: Any] = [
            "🎯 target": String(describing: target),
            "🌐 url": url,
            "💥 error": error.localizedDescription,
            "🔢 errorCode": error.errorCode,
            "📊 statusCode": statusCode ?? "N/A"
//            "📝 errorHeaders": errorHeaders
        ]
        
        // 에러 응답 바디 추가
        if let errorResponse = error.response,
           let errorData = String(data: errorResponse.data, encoding: .utf8) {
            if let jsonObject = try? JSONSerialization.jsonObject(with: errorResponse.data, options: []),
               let jsonData = try? JSONSerialization.data(
                withJSONObject: jsonObject,
                options: [.prettyPrinted, .sortedKeys]
               ),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                
                let truncatedError = jsonString.count > 500 ? String(jsonString.prefix(500)) + "\n..." : jsonString
                metaData.updateValue(truncatedError, forKey: "errorResponse")
            } else {
                let truncatedError = errorData.count > 300 ? String(errorData.prefix(300)) + "..." : errorData
                metaData.updateValue(truncatedError, forKey: "errorResponse")
            }
        } else if let errorResponse = error.response, !errorResponse.data.isEmpty {
            let dataDescription = errorResponse.data.count > 100 ?
                "Binary error data (\(errorResponse.data.count) bytes)" : errorResponse.data.description
            metaData.updateValue(dataDescription, forKey: "errorResponse")
        }

        logger.error("❌ 네트워크 요청 실패\n🌐 url: \(url)", metadata: metaData)
    }
    
}
