//
//  DataTransferError.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

public enum DataTransferError: Error {
    case data
    case response
    case status(code: Int)
    case error(error: Error)
    case parse(error: Error)
}
