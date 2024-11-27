//
//  TestDataProvider.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 21.11.24.
//

@testable import DataProvider

struct TestDataProvider<Result, ProviderError: Error>: DataProvider {
    let result: Result
    let error: ProviderError?

    init(result: Result, error: ProviderError? = nil) {
        self.result = result
        self.error = error
    }

    func fetch() async throws(ProviderError) -> Result {
        if let error {
            throw error
        }
        return result
    }
}
