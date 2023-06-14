//
//  DataTransferError.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

import Foundation

public enum DataTransferError: Error {
    case data
    case response
    case status(code: Int, data: Data)
    case error(error: Error)
    case parse(error: Error)
}
