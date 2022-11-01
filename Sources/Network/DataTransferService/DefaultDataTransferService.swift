//
//  DefaultDataTransferService.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

import Foundation

public class DefaultDataTransferService: DataTransferService {
    private let session: URLSession

    public required convenience init() {
        self.init(session: .shared)
    }

    public required init(session: URLSession) {
        self.session = session
    }

    public func request<T: Decodable>(with request: URLRequest) async throws -> T {
        /*let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ..< 300).contains(httpResponse.statusCode)
        else { throw DataTransferError.unknown }

        let responseData = try JSONDecoder().decode(T.self, from: data)

        return responseData*/
        throw DataTransferError.unknown
    }

    public func request(with request: URLRequest) async throws -> Data {
        return .init() // try await session.data(for: request).0
    }
}
