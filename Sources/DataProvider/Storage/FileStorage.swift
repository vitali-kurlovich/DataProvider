//
//  FileStorage.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 29.11.24.
//

import Foundation
import OSLog

public struct FileAttributes: Hashable, Sendable {
    public let creationDate: Date
    public let modificationDate: Date
    public let fileSize: UInt

    public init(creationDate: Date, modificationDate: Date, fileSize: UInt) {
        self.creationDate = creationDate
        self.modificationDate = modificationDate
        self.fileSize = fileSize
    }
}

public
struct FileStorage: Sendable, ParametredDataStorage {
    public typealias Params = String
    public typealias Stored = Data

    public enum StorageError: Error {
        case anyError(any Error)
        case readingError(any Error)
        case writingError(any Error)
        case deletingError(any Error)
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
        return FileManager.default.fileExists(atPath: url.path())
    }

    public func read(_ params: Params) async throws(StorageError) -> Data {
        let url = try fileUrl(params)
        do {
            logger?.info("Read from: \(url)")
            let data = try Data(contentsOf: url, options: readingOptions)
            logger?.debug("\(String(decoding: data, as: UTF8.self))")

            return data
        } catch {
            let error = StorageError.readingError(error)
            logger?.error("\(error.localizedDescription)")
            throw error
        }
    }

    public func write(_ params: Params, data: Data) async throws(StorageError) {
        let url = try fileUrl(params)

        let folderPath = url.deletingLastPathComponent()

        do {
            if !FileManager.default.fileExists(atPath: folderPath.path()) {
                try FileManager.default.createDirectory(atPath: folderPath.path(), withIntermediateDirectories: true)
            }

            try data.write(to: url, options: writingOptions)
            logger?.info("Write to: \(url)")
            logger?.debug("\(String(decoding: data, as: UTF8.self))")

        } catch {
            let error = StorageError.writingError(error)
            logger?.error("\(error.localizedDescription)")
            throw error
        }
    }

    public func delete(_ params: String) async throws(StorageError) {
        let url = try fileUrl(params)
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            let error = StorageError.deletingError(error)
            logger?.error("\(error.localizedDescription)")
            throw error
        }
    }

    public func attributes(_ params: Params) async throws(StorageError) -> FileAttributes {
        let url = try fileUrl(params)
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path())

            let creationDate = attrs[.creationDate] as! Date
            let modificationDate = attrs[.modificationDate] as! Date
            let fileSize = attrs[.size] as! Int

            return FileAttributes(creationDate: creationDate,
                                  modificationDate: modificationDate,
                                  fileSize: UInt(fileSize))

        } catch {
            let error = StorageError.anyError(error)
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

    func fileUrl(_ params: Params) throws(StorageError) -> URL {
        guard let url = filePath(params) else {
            let error = StorageError.incorrectFilePath
            logger?.error("\(error.localizedDescription)")
            throw error
        }

        return url
    }
}
