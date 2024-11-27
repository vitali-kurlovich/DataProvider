//
//  MapDataProvider.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 21.11.24.
//

public struct MapDataProvider<Provider: DataProvider, Result>: DataProvider {
    public typealias ProviderError = Provider.ProviderError

    let provider: Provider
    let convertResult: (Provider.Result) -> Result

    public init(provider: Provider, convertResult: @escaping (Provider.Result) -> Result) {
        self.provider = provider
        self.convertResult = convertResult
    }

    public func fetch() async throws(Provider.ProviderError) -> Result {
        let result = try await provider.fetch()
        return convertResult(result)
    }
}

public extension DataProvider {
    func map<TargetResult>(_ convertResult: @escaping (Self.Result) -> TargetResult) -> MapDataProvider<Self, TargetResult> {
        .init(provider: self, convertResult: convertResult)
    }
}
