//
//  DataProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

public protocol DataProvider<Result, ProviderError>: Sendable {
    associatedtype Result: Sendable
    associatedtype ProviderError: Error

    func fetch() async throws(ProviderError) -> Result
}
