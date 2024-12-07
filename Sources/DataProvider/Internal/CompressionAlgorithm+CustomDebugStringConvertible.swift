//
//  CompressionAlgorithm+CustomDebugStringConvertible.swift
//  DataProvider
//
//  Created by Vitali Kurlovich on 7.12.24.
//

import Foundation

extension NSData.CompressionAlgorithm {
    var debugDescription: String {
        switch self {
        case .lzfse:
            return "lzfse"
        case .lz4:
            return "lz4"
        case .lzma:
            return "lzma"
        case .zlib:
            return "zlib"
        @unknown default:
            return "unknown"
        }
    }
}
