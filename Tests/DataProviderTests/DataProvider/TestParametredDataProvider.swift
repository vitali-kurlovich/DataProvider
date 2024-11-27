//
//  TestParametredDataProvider.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 21.11.24.
//

@testable import DataProvider

struct TestParametredDataProvider<Params, ProviderError: Error>: ParametredDataProvider {
    typealias Result = Params
    let error: ProviderError?

    init(error: ProviderError? = nil) {
        self.error = error
    }

    func fetch(_ param: Params) async throws(ProviderError) -> Result {
        if let error {
            throw error
        }
        return param
    }
}
