//
//  DataProviderError.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 18.11.24.
//

import Foundation
import HTTPTypes

public enum DataProviderErrorKind: Sendable {
    case anyError(any Error)
    /// The status code is outside the range of 100...599.
    case invalid
    /// The status code is a client error (4xx).
    case clientError(statusCode: Int, Data?)
    /// The status code is a server error (5xx).
    case serverError(statusCode: Int, Data?)

    case decodingError(DecodingError)

    case unknown
}

public protocol DataProviderErrorProtocol: Error, Sendable {
    var error: (any Error)? { get }
    var status: HTTPResponse.Status? { get }
    var data: Data? { get }

    var kind: DataProviderErrorKind { get }
}

public extension DataProviderErrorProtocol {
    var kind: DataProviderErrorKind {
        if let decodingError = error as? DecodingError {
            return .decodingError(decodingError)
        }

        if let error {
            return .anyError(error)
        }

        guard let status else { return .unknown }

        switch status.kind {
        case .invalid:
            return .invalid
        case .informational, .successful, .redirection:
            assertionFailure("Invalid status")
            return .unknown
        case .clientError:
            return .clientError(statusCode: status.code, data)
        case .serverError:
            return .serverError(statusCode: status.code, data)
        }
    }
}

public struct DataProviderError: DataProviderErrorProtocol, Sendable {
    public let error: (any Error)?

    public let status: HTTPResponse.Status?
    public let data: Data?

    init(error: (any Error)? = nil, status: HTTPResponse.Status? = nil, data: Data? = nil) {
        precondition(error != nil || status != nil)

        self.error = error
        self.status = status
        self.data = data
    }
}

public extension DataProviderError {
    init(_ dataProviderError: some DataProviderErrorProtocol) {
        self.init(error: dataProviderError.error, status: dataProviderError.status, data: dataProviderError.data)
    }

    init(error: any Error) {
        self.init(error: error, status: nil, data: nil)
    }

    init(status: HTTPResponse.Status, data: Data? = nil) {
        self.init(error: nil, status: status, data: data)
    }
}
