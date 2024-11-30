//
//  ParametredDataStorage.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import Foundation

public protocol ParametredDataStorage<Params, Stored, StorageError>: Sendable {
    associatedtype Params: Sendable
    associatedtype Stored: Sendable
    associatedtype StorageError: Error

    func isExists(_ params: Params) async -> Bool
    func read(_ params: Params) async throws(StorageError) -> Stored
    func write(_ params: Params, data: Stored) async throws(StorageError)
}
