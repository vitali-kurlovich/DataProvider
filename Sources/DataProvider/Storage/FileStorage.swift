//
//  FileStorage.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 29.11.24.
//

import Foundation

public struct FileStorage: Sendable, ParametredDataStorage {
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

    public init(searchPathDirectory: FileManager.SearchPathDirectory = .cachesDirectory,
                readingOptions: Data.ReadingOptions = [],
                writingOptions: Data.WritingOptions = [.atomic])
    {
        self.searchPathDirectory = searchPathDirectory
        self.readingOptions = readingOptions
        self.writingOptions = writingOptions
    }

    public func isExists(_ params: Params) async -> Bool {
        guard let url = filePath(params) else { return false }
        return FileManager.default.fileExists(atPath: url.absoluteString)
    }

    public func read(_ params: Params) async throws(StorageError) -> Data {
        guard let url = filePath(params) else {
            throw StorageError.incorrectFilePath
        }
        do {
            return try Data(contentsOf: url)
        } catch {
            throw StorageError.readingError(error)
        }
    }

    public func write(_ params: Params, data: Data) async throws(StorageError) {
        guard let url = filePath(params) else {
            throw StorageError.incorrectFilePath
        }
        let folderPath = url.deletingLastPathComponent()

        do {
            if !FileManager.default.fileExists(atPath: folderPath.absoluteString) {
                try FileManager.default.createDirectory(at: folderPath, withIntermediateDirectories: true)
            }
            try data.write(to: url)

        } catch {
            throw StorageError.writingError(error)
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
