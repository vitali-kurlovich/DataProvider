//
//  URLSessionProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

@available(iOS 13.0, *)
@available(macOS 10.15, *)
public struct URLSessionProvider: ParametredDataProvider {
    public typealias Result = (Data, HTTPResponse)
    public typealias Params = HTTPRequest

    public typealias ProviderError = DataProviderError

    let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func fetch(_ params: Params) async throws(ProviderError) -> Result {
        do {
            let (data, response) = try await urlSession.data(for: params)

            let status = response.status

            switch status.kind {
            case .informational, .successful, .redirection:
                break
            case .invalid, .clientError, .serverError:
                throw DataProviderError(status: status, data: data)
            }

            return (data, response)

        } catch {
            throw DataProviderError(error: error)
        }
    }
}
