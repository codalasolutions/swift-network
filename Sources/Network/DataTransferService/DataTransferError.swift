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
    private var separator: String { "$" }
    public var errorDescription: String? {
        switch self {
        case .data:             return "DataTransferError\(separator)data"
        case .response:         return "DataTransferError\(separator)response"
        case .status(let code): return "DataTransferError\(separator)status\(separator)\(code)"
        case .error(let error): return "DataTransferError\(separator)error\(separator)\(error.localizedDescription)"
        case .parse(let error): return "DataTransferError\(separator)parse\(separator)\(error.localizedDescription)"
        }
    }
}
