//
//  ParamsReducer.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 21.11.24.
//

public struct ParamsReducer<Provider: ParametredDataProvider>: DataProvider {
    public typealias ProviderError = Provider.ProviderError
    public typealias Result = Provider.Result

    let params: Provider.Params
    let provider: Provider

    public init(params: Provider.Params, provider: Provider) {
        self.params = params
        self.provider = provider
    }

    public func fetch() async throws(ProviderError) -> Result {
        try await provider.fetch(params)
    }
}

public extension ParametredDataProvider {
    func param(_ param: Self.Params) -> ParamsReducer<Self> {
        .init(params: param, provider: self)
    }
}
