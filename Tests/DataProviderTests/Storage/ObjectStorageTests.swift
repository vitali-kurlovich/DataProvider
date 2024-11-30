//
//  ObjectStorageTests.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import DataProvider
import Foundation
import Testing

@Test func objectStorage() async throws {
    
    struct Object: Codable, Equatable {
        let int: Int
        let string: String
    }
    
    let fileStorage = FileStorage()
    let fileName = "Test/\(UUID().uuidString).json"

    let objectStorage = ObjectStorage(storage: fileStorage, decoder: JSONDecoder(), encoder: JSONEncoder())

    let object = Object(int: 100, string: "String")
    try await objectStorage.write(object: object, fileName)
    let readObject = try await objectStorage.read(Object.self, fileName)

    #expect(object == readObject)
}
