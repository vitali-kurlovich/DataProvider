//
//  DataProviderTests.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 21.11.24.
//

import DataProvider
import Foundation
import Testing

@Test func mapDataProvider() async throws {
    let provider = TestDataProvider<Int, Never>(result: 10)

    let mapProvider = provider.map { value -> String in
        String(value)
    }

    let result = await mapProvider.fetch()

    #expect(result == "10")
}

@Test func jsonDecodingDataProvider() async throws {
    struct TestData: Decodable, Equatable {
        let value: String
        let int: Int
    }

    let json = """
            { "value": "Hello", "int": 10 }
    """

    let provider = TestDataProvider<String, DataProviderError>(result: json)

    let jsonProvider = provider.map { string -> Data in
        string.data(using: .utf8)!
    }.decode(TestData.self)

    let result = try await jsonProvider.fetch()

    #expect(result == TestData(value: "Hello", int: 10))
}
