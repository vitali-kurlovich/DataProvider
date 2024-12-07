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

extension FileAttributes: CustomDebugStringConvertible {
    public var debugDescription: String {
        "{ creationDate: \(creationDate), modificationDate: \(modificationDate), fileSize: \(fileSize) }"
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

    public let searchPathDirectory: FileManager.SearchPathDirectory
    public let readingOptions: Data.ReadingOptions
    public let writingOptions: Data.WritingOptions

    public let compressionAlgorithm: NSData.CompressionAlgorithm?

    public let logger: Logger?
    public let signposter: OSSignposter?

    public init(searchPathDirectory: FileManager.SearchPathDirectory = .cachesDirectory,
                readingOptions: Data.ReadingOptions = [],
                writingOptions: Data.WritingOptions = [.atomic],
                compressionAlgorithm: NSData.CompressionAlgorithm? = nil,
                logger: Logger? = nil,
                signposter: OSSignposter? = nil)
    {
        self.searchPathDirectory = searchPathDirectory
        self.readingOptions = readingOptions
        self.writingOptions = writingOptions

        self.compressionAlgorithm = compressionAlgorithm

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

            let state = signpostBeginRead()

            defer {
                signpostEndRead(state: state)
            }

            let data = try Data(contentsOf: url, options: readingOptions)
            logger?.debug("Read \(data.count) bytes")

            if let compressionAlgorithm {
                logger?.debug("Decompress using: \(compressionAlgorithm.debugDescription)")

                let state = signpostBeginDecompress()

                let mutableData = NSMutableData(data: data)

                try mutableData.decompress(using: compressionAlgorithm)
                let data = mutableData as Data

                signpostEndDecompress(state: state)

                logger?.debug("Decompressed size \(data.count) bytes")
                logger?.logData(data)

                return data
            }

            logger?.logData(data)

            return data
        } catch {
            let error = StorageError.readingError(error)
            logger?.logError(error)
            throw error
        }
    }

    public func write(_ params: Params, data: Data) async throws(StorageError) {
        let url = try fileUrl(params)

        let folderPath = url.deletingLastPathComponent()

        do {
            let state = signpostBeginWrite()

            defer {
                signpostEndWrite(state: state)
            }

            if !FileManager.default.fileExists(atPath: folderPath.path()) {
                try FileManager.default.createDirectory(atPath: folderPath.path(), withIntermediateDirectories: true)
            }

            if let compressionAlgorithm {
                logger?.debug("Compress using: \(compressionAlgorithm.debugDescription)")

                let state = signpostBeginCompress()

                let mutableData = NSMutableData(data: data)
                try mutableData.compress(using: compressionAlgorithm)

                let compressedData = mutableData as Data

                signpostEndCompress(state: state)

                logger?.debug("Source size \(data.count), compressed size \(compressedData.count) bytes.")

                try write(to: url, data: compressedData)

                logger?.debug("Original data")
                logger?.logData(data)

            } else {
                try write(to: url, data: data)
                logger?.logData(data)
            }

        } catch {
            let error = StorageError.writingError(error)
            logger?.logError(error)
            throw error
        }
    }

    public func delete(_ params: String) async throws(StorageError) {
        let url = try fileUrl(params)
        do {
            logger?.debug("Delete item: \(url)")
            try FileManager.default.removeItem(at: url)
        } catch {
            let error = StorageError.deletingError(error)
            logger?.logError(error)
            throw error
        }
    }

    public func attributes(_ params: Params) async throws(StorageError) -> FileAttributes {
        let url = try fileUrl(params)
        do {
            logger?.debug("Read file attributes: \(url)")
            let attrs = try FileManager.default.attributesOfItem(atPath: url.path())

            let creationDate = attrs[.creationDate] as! Date
            let modificationDate = attrs[.modificationDate] as! Date
            let fileSize = attrs[.size] as! Int

            let fileAttributes = FileAttributes(creationDate: creationDate,
                                                modificationDate: modificationDate,
                                                fileSize: UInt(fileSize))

            logger?.debug("File attributes: \(fileAttributes.debugDescription) for \(url)")

            return fileAttributes

        } catch {
            let error = StorageError.anyError(error)
            logger?.logError(error)
            throw error
        }
    }
}

private
extension FileStorage {
    func write(to url: URL, data: Data) throws {
        try data.write(to: url, options: writingOptions)

        guard let logger else { return }

        logger.info("Write to: \(url)")
        logger.debug("Write \(data.count) bytes")
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
            logger?.logError(error)
            throw error
        }

        return url
    }
}

private
extension FileStorage {
    func signpostBeginRead() -> OSSignpostIntervalState? {
        guard let signposter else { return nil }
        let signpostID = signposter.makeSignpostID()
        return signposter.beginInterval("Read", id: signpostID)
    }

    func signpostEndRead(state: OSSignpostIntervalState?) {
        guard let signposter, let state else { return }
        signposter.emitEvent("Read complete.")
        signposter.endInterval("Read", state)
    }

    func signpostBeginWrite() -> OSSignpostIntervalState? {
        guard let signposter else { return nil }
        let signpostID = signposter.makeSignpostID()
        return signposter.beginInterval("Write", id: signpostID)
    }

    func signpostEndWrite(state: OSSignpostIntervalState?) {
        guard let signposter, let state else { return }
        signposter.emitEvent("Write complete.")
        signposter.endInterval("Write", state)
    }

    func signpostBeginCompress() -> OSSignpostIntervalState? {
        guard let signposter else { return nil }
        let signpostID = signposter.makeSignpostID()
        return signposter.beginInterval("Compress", id: signpostID)
    }

    func signpostEndCompress(state: OSSignpostIntervalState?) {
        guard let signposter, let state else { return }
        signposter.emitEvent("Compress complete.")
        signposter.endInterval("Compress", state)
    }

    func signpostBeginDecompress() -> OSSignpostIntervalState? {
        guard let signposter else { return nil }
        let signpostID = signposter.makeSignpostID()
        return signposter.beginInterval("Decompress", id: signpostID)
    }

    func signpostEndDecompress(state: OSSignpostIntervalState?) {
        guard let signposter, let state else { return }
        signposter.emitEvent("Decompress complete.")
        signposter.endInterval("Decompress", state)
    }
}
