//
//  FileStorage.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 29.11.24.
//

import Foundation
import OSLog

public
struct FileStorage: Sendable, ParametredDataStorage {
    public typealias Params = String
    public typealias Stored = Data

    public enum StorageError: Error {
        case readingError(any Error)
        case writingError(any Error)
        case incorrectFilePath
    }

    let searchPathDirectory: FileManager.SearchPathDirectory
    let readingOptions: Data.ReadingOptions
    let writingOptions: Data.WritingOptions

    let logger: Logger?
    let signposter: OSSignposter?

    public init(searchPathDirectory: FileManager.SearchPathDirectory = .cachesDirectory,
                readingOptions: Data.ReadingOptions = [],
                writingOptions: Data.WritingOptions = [.atomic],
                logger: Logger? = nil,
                signposter: OSSignposter? = nil)
    {
        self.searchPathDirectory = searchPathDirectory
        self.readingOptions = readingOptions
        self.writingOptions = writingOptions
        self.logger = logger
        self.signposter = signposter
    }

    public func isExists(_ params: Params) async -> Bool {
        guard let url = filePath(params) else { return false }
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }

    public func read(_ params: Params) async throws(StorageError) -> Data {
        guard let url = filePath(params) else {
            let error = StorageError.incorrectFilePath
            logger?.error("\(error.localizedDescription)")
            throw error
        }
        do {
            logger?.info("Read from: \(url)")
            let data = try Data(contentsOf: url)
            logger?.debug("\(String(decoding: data, as: UTF8.self))")
            return data
        } catch {
            let error = StorageError.readingError(error)
            logger?.error("\(error.localizedDescription)")
            throw error
        }
    }

    public func write(_ params: Params, data: Data) async throws(StorageError) {
        guard let url = filePath(params) else {
            let error = StorageError.incorrectFilePath
            logger?.error("\(error.localizedDescription)")
            throw error
        }
        let folderPath = url.deletingLastPathComponent()

        do {
            if !FileManager.default.fileExists(atPath: folderPath.absoluteString) {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)
            }

            try data.write(to: url)
            logger?.info("Write to: \(url)")
            logger?.debug("\(String(decoding: data, as: UTF8.self))")

        } catch {
            let error = StorageError.writingError(error)
            logger?.error("\(error.localizedDescription)")
            throw error
        }
    }
}

private
extension FileStorage {
    func filePath(_ params: Params) -> URL? {
        let directory = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first
        return directory?.appending(path: params)
    }
}
