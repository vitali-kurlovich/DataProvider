//
//  FileCacheStorage.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import Foundation
import OSLog

public
struct FileCacheStorage: Sendable, ParametredDataStorage {
    public typealias Params = String
    public typealias Stored = Data

    public typealias StorageError = FileStorage.StorageError

    public let cachePath: String
    private let fileStorage: FileStorage

    public init(cachePath: String,
                searchPathDirectory: FileManager.SearchPathDirectory = .cachesDirectory,
                readingOptions: Data.ReadingOptions = [],
                writingOptions: Data.WritingOptions = [.atomic],
                logger: Logger? = nil,
                signposter: OSSignposter? = nil)
    {
        self.cachePath = cachePath
        fileStorage = FileStorage(
            searchPathDirectory: searchPathDirectory,
            readingOptions: readingOptions,
            writingOptions: writingOptions,
            logger: logger,
            signposter: signposter
        )
    }

    public func isExists(_ params: Params) async -> Bool {
        await fileStorage.isExists(path(params))
    }

    public func read(_ params: Params) async throws(StorageError) -> Data {
        try await fileStorage.read(path(params))
    }

    public func write(_ params: Params, data: Data) async throws(StorageError) {
        try await fileStorage.write(path(params), data: data)
    }
}

private
extension FileCacheStorage {
    func path(_ params: Params) -> String {
        if cachePath.hasSuffix("/") {
            return cachePath + params
        }
        return cachePath + "/" + params
    }
}
