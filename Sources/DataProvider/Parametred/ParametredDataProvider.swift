//
//  ParametredDataProvider.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 21.11.24.
//

public protocol ParametredDataProvider<Params, Result, ProviderError> {
    associatedtype Params
    associatedtype Result
    associatedtype ProviderError: Error

    func fetch(_ params: Params) async throws(ProviderError) -> Result
}
