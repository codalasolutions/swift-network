//
//  DataTransferService.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

import Foundation

public protocol DataTransferService {
    init() // instantiates with URLSession.shared
    init(session: URLSession)

    func request<T: Decodable>(with request: URLRequest) async throws -> T // json
    func request(with request: URLRequest) async throws -> Data
}
