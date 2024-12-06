//
//  FileStorageTests.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 29.11.24.
//

import DataProvider
import Foundation
import OSLog
import Testing

@Test func fileStorage() async throws {
    let logger = Logger(subsystem: "fileStorageTest", category: "Filesystem")

    let storage = FileStorage(logger: logger)
    let fileName = "Test/\(UUID().uuidString).txt"

    let data = Data("Hello".utf8)
    try await storage.write(fileName, data: data)

    do {
        let isExists = await storage.isExists(fileName)
        #expect(isExists)
    }

    let attrs = try await storage.attributes(fileName)

    #expect(attrs.fileSize == 5)

    let readData = try await storage.read(fileName)

    let string = String(decoding: readData, as: UTF8.self)

    #expect(string == "Hello")

    try await storage.delete(fileName)

    do {
        let isExists = await storage.isExists(fileName)
        #expect(isExists == false)
    }
}
