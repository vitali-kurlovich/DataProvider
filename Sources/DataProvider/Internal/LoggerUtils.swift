//
//  LoggerUtils.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 7.12.24.
//

import HTTPTypes
import HTTPTypesFoundation
import OSLog

private extension Int {
    static let maxLoggedDataSize = 2048
}

extension Logger {
    func logError(_ error: Error) {
        self.error("\(error.localizedDescription)")
    }
}

// MARK: - Data

extension Logger {
    func logData(_ data: Data) {
        if data.count <= .maxLoggedDataSize {
            debug("\(String(decoding: data, as: UTF8.self))")
        } else {
            let endIndex = data.index(data.startIndex, offsetBy: .maxLoggedDataSize)
            let range = data.startIndex ..< endIndex

            debug("\(String(decoding: data[range], as: UTF8.self))")
            debug("Skipped by \(.maxLoggedDataSize). Original size is \(data.count) bytes")
        }
    }
}

// MARK: - HTTP

extension Logger {
    func logRequest(_ request: HTTPRequest) {
        info("\(request.debugDescription)")
        debug("\(request.headerFields.debugDescription)")
    }

    func logResponse(_ response: HTTPResponse) {
        info("\(response.debugDescription)")
    }
}
