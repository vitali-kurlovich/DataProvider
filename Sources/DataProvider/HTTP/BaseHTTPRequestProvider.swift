//
//  BaseHTTPRequestProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import Foundation
import HTTPTypes

public struct BaseHTTPRequestProvider: HTTPRequestProvider {
    public let baseURL: URL
    public let method: HTTPRequest.Method
    public let headerFields: HTTPFields

    public init(_ baseURL: URL, method: HTTPRequest.Method = .get, headerFields: HTTPFields = [:]) {
        self.baseURL = baseURL
        self.method = method
        self.headerFields = headerFields
    }

    public func request() -> HTTPRequest {
        var headerFields = self.headerFields

        if !headerFields.contains(.referer) {
            var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
            components?.query = nil

            if let value = components?.string, !value.isEmpty {
                let field = HTTPField(name: .referer, value: value)
                headerFields.append(field)
            }
        }

        return HTTPRequest(method: method, url: baseURL, headerFields: headerFields)
    }
}
