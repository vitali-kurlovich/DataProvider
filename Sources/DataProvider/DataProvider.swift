//
//  DataProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

public protocol DataProvider<Result, ProviderError> {
    associatedtype Result
    associatedtype ProviderError: Error

    func fetch() async throws(ProviderError) -> Result
}
