//
//  LoggerSettings.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 7.12.24.
//

import OSLog
import HTTPTypes
import HTTPTypesFoundation

extension Int {
    fileprivate static let maxLoggedDataSize = 2048
}

extension Logger {
    func logError(_ error: Error ) {
        self.error("\(error.localizedDescription)")
    }
}

// MARK: - Data
extension Logger {
    func logData(_ data: Data ) {
        
        if data.count <= .maxLoggedDataSize {
            self.debug("\(String(decoding: data, as: UTF8.self))")
        } else {
            let endIndex = data.index(data.startIndex, offsetBy: .maxLoggedDataSize)
            let range = data.startIndex ..< endIndex
            
            self.debug("\(String(decoding: data[range], as: UTF8.self))")
            self.debug("Skipped by \(.maxLoggedDataSize). Original size is \(data.count) bytes")
            
        }
    }
}
 
// MARK: - HTTP
extension Logger {
    func logRequest(_ request: HTTPRequest) {
        self.info("\(request.debugDescription)")
        self.debug("\(request.headerFields.debugDescription)")
    }
    
    func logResponse(_ response:  HTTPResponse) {
       self.info("\(response.debugDescription)")
    }
    
}
