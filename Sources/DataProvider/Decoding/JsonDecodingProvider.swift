//
//  JsonDecodingProvider.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

import Foundation

public struct JsonDecodingProvider<Result: Decodable, Provider: DataProvider>: DataProvider
    where Provider.Result == Data, Provider.ProviderError == DataProviderError
{
    public typealias ProviderError = DataProviderError

    let decoder: JSONDecoder
    let provider: Provider

    public init(_: Result.Type, decoder: JSONDecoder = JSONDecoder(), provider: Provider) {
        self.decoder = decoder
        self.provider = provider
    }

    public func fetch() async throws(ProviderError) -> Result {
        do {
            let data = try await provider.fetch()
            return try decoder.decode(Result.self, from: data)
        } catch {
            throw DataProviderError(error: error)
        }
    }
}

public extension DataProvider where Self.Result == Data {
    func decode<Object: Decodable>(_ type: Object.Type, decoder: JSONDecoder = JSONDecoder()) -> JsonDecodingProvider<Object, Self> {
        .init(type, decoder: decoder, provider: self)
    }
}
