import DataProvider
import Foundation
import Testing

@Test func removeParams() async throws {
    let provider = TestParametredDataProvider<Int, Never>()
    let result = await provider.param(10).fetch()
    #expect(result == 10)
}

@Test func mapParametredDataProvider() async throws {
    let provider = TestParametredDataProvider<Int, Never>()

    let mapProvider = provider.map { value -> String in
        String(value)
    }

    let result = await mapProvider.fetch(5)

    #expect(result == "5")
}

@Test func jsonDecodingParametredDataProvider() async throws {
    let provider = TestParametredDataProvider<String, DataProviderError>()

    struct TestData: Decodable, Equatable {
        let value: String
        let int: Int
    }

    let jsonProvider = provider.map { string -> Data in
        string.data(using: .utf8)!
    }.decode(TestData.self)

    let json = """
            { "value": "Hello", "int": 10 }
    """

    let result = try await jsonProvider.fetch(json)

    #expect(result == TestData(value: "Hello", int: 10))
}
