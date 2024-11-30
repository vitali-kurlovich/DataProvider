//
//  FileStorageTests.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 29.11.24.
//

import DataProvider
import Foundation
import Testing

@Test func fileStorage() async throws {
    let storage = FileStorage()

    let fileName = "Test/\(UUID().uuidString).txt"

    let data = Data("Hello".utf8)
    try await storage.write(fileName, data: data)

    let readData = try await storage.read(fileName) 

    let string = String(decoding: readData, as: UTF8.self)

    #expect(string == "Hello")
}
