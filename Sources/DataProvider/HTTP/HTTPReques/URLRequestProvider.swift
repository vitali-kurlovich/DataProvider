//
//  URLRequestProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 19.11.24.
//

import Foundation
import HTTPTypes

public struct URLRequestProvider: HTTPRequestProvider {
    let url: URL

    public init(url: URL) {
        self.url = url
    }

    public func request() -> HTTPRequest {
        let privider = BaseHTTPRequestProvider(url)
        return privider.request()
    }
}
