//
//  DataTransferError.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

import Foundation

public enum DataTransferError: Error {
    case data
    case response
    case status(code: Int)
    case error(error: Error)
    case parse(error: Error)
}

extension DataTransferError: LocalizedError {
    var prefix: String { "DataTransferError" }
    var separator: String { "$" }

    public var errorDescription: String? {
        switch self {
        case .data:             return "\(prefix)\(separator)data"
        case .response:         return "\(prefix)\(separator)response"
        case .status(let code): return "\(prefix)\(separator)status\(separator)\(code)"
        case .error(let error): return "\(prefix)\(separator)error\(separator)\(error.localizedDescription)"
        case .parse(let error): return "\(prefix)\(separator)parse\(separator)\(error.localizedDescription)"
        }
    }
}
