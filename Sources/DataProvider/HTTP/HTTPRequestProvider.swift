//
//  HTTPRequestProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import HTTPTypes

public protocol HTTPRequestProvider: Sendable {
    func request() -> HTTPRequest
}
