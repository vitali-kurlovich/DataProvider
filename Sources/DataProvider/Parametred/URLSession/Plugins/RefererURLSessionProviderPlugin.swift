//
//  RefererURLSessionProviderPlugin.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 6.12.24.
//

import Foundation
import HTTPTypes
import HTTPTypesFoundation

public struct RefererURLSessionProviderPlugin: URLSessionProviderPlugin {
    public init() {}

    public func prepare(_ request: HTTPTypes.HTTPRequest) -> HTTPTypes.HTTPRequest {
        if request.headerFields.contains(.referer) {
            return request
        }

        guard let url = request.url,
              var components = URLComponents(url: url, resolvingAgainstBaseURL: true)
        else {
            return request
        }

        components.query = nil

        var request = request

        if let value = components.string, !value.isEmpty {
            let field = HTTPField(name: .referer, value: value)
            request.headerFields.append(field)
        }

        return request
    }
}
