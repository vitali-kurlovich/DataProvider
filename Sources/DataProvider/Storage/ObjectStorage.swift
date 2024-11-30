//
//  ObjectStorage.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import Combine
import Foundation

public
struct ObjectStorage<Storage: ParametredDataStorage,
    Params: Sendable,
    Decoder: TopLevelDecoder & Sendable,
    Encoder: TopLevelEncoder & Sendable>: Sendable
    where Storage.Stored == Decoder.Input,
    Storage.Stored == Encoder.Output,
    Storage.Params == Params
{
    public let decoder: Decoder
    public let encoder: Encoder

    public let storage: Storage

    public enum ObjectStorageError: Error {
        case storageError(Storage.StorageError)
        case noObjectInStorage
        case decoderError(any Error)
        case encoderError(any Error)
    }

    public init(storage: Storage, decoder: Decoder, encoder: Encoder) {
        self.decoder = decoder
        self.encoder = encoder
        self.storage = storage
    }

    public func isExists(_ params: Params) async -> Bool {
        await storage.isExists(params)
    }

    public func read<T>(_ type: T.Type, _ params: Params) async throws(ObjectStorageError) -> T where T: Decodable {
        do {
            let input = try await storage.read(params)
            return try decoder.decode(type, from: input)
        } catch let error as Storage.StorageError {
            throw ObjectStorageError.storageError(error)
        } catch {
            throw ObjectStorageError.decoderError(error)
        }
    }

    public func write<T>(object: T, _ params: Params) async throws(ObjectStorageError) where T: Encodable {
        do {
            let output = try encoder.encode(object)
            try await storage.write(params, data: output)
        } catch let error as Storage.StorageError {
            throw ObjectStorageError.storageError(error)
        } catch {
            throw ObjectStorageError.encoderError(error)
        }
    }
}
