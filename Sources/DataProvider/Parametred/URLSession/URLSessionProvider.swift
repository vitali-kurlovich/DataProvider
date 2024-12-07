//
//  URLSessionProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation
import OSLog

public protocol URLSessionProviderPlugin: Sendable {
    func prepare(_ request: HTTPRequest) -> HTTPRequest
}

public struct URLSessionProvider: ParametredDataProvider {
    public typealias Result = (Data, HTTPResponse)
    public typealias Params = HTTPRequest

    public typealias ProviderError = DataProviderError

    public let urlSession: URLSession
    public let plugins: [any URLSessionProviderPlugin]

    let logger: Logger?
    let signposter: OSSignposter?

    public init(urlSession: URLSession = .shared,
                plugins: [any URLSessionProviderPlugin] = [],
                logger: Logger? = nil,
                signposter: OSSignposter? = nil)
    {
        self.urlSession = urlSession
        self.plugins = plugins
        self.logger = logger
        self.signposter = signposter
    }

    public func fetch(_ params: Params) async throws(ProviderError) -> Result {
        do {
            var params = params

            for plugin in plugins {
                params = plugin.prepare(params)
            }

            let state = signpostBeginRequest()

            defer {
                signpostEndRequest(state: state)
            }

            logger?.logRequest(params)

            let (data, response) = try await urlSession.data(for: params)
            logger?.logResponse(response)
            logger?.logData(data)

            let status = response.status
            switch status.kind {
            case .informational, .successful, .redirection:
                break
            case .invalid, .clientError, .serverError:
                let error = DataProviderError(status: status, data: data)
                logger?.logError(error)
                throw error
            }

            return (data, response)

        } catch {
            let error = DataProviderError(error: error)
            logger?.logError(error)
            throw error
        }
    }
}

private
extension URLSessionProvider {
    func signpostBeginRequest() -> OSSignpostIntervalState? {
        guard let signposter else { return nil }
        let signpostID = signposter.makeSignpostID()
        return signposter.beginInterval("Fetch request", id: signpostID)
    }

    func signpostEndRequest(state: OSSignpostIntervalState?) {
        guard let signposter, let state else { return }
        signposter.emitEvent("Fetch complete.")
        signposter.endInterval("Fetch request", state)
    }
}
