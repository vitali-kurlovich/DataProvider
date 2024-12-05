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

    let urlSession: URLSession
    let logger: Logger?

    let signposter: OSSignposter?

    let plugins: [any URLSessionProviderPlugin]

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

            logger?.info("\(params.debugDescription)")
            logger?.debug("\(params.headerFields.debugDescription)")

            let (data, response) = try await urlSession.data(for: params)
            logger?.info("\(response.debugDescription)")
            logger?.debug("\(String(decoding: data, as: UTF8.self))")

            let status = response.status
            switch status.kind {
            case .informational, .successful, .redirection:
                break
            case .invalid, .clientError, .serverError:
                let error = DataProviderError(status: status, data: data)
                logger?.error("\(error.localizedDescription)")
                throw error
            }

            return (data, response)

        } catch {
            logger?.error("\(error.localizedDescription)")
            throw DataProviderError(error: error)
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
