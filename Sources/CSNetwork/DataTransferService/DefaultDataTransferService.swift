//
//  DefaultDataTransferService.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

import Foundation

open class DefaultDataTransferService: DataTransferService {
    public var session: URLSession
    public var decoder: JSONDecoder

    public init(session: URLSession = .shared, decoder: JSONDecoder = .init()) {
        self.session = session
        self.decoder = decoder
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func request<T: Decodable & Sendable>(with request: URLRequest) async throws -> T {
        try await self.request(with: request).data
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func request<T: Decodable & Sendable>(with request: URLRequest) async throws -> Response<T> {
        try await withUnsafeThrowingContinuation { continuation in
            self.request(with: request) { (result: Result<Response<T>, Error>) in
                switch result {
                case .success(let response):
                    continuation.resume(returning: response)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func request(with request: URLRequest) async throws -> Data {
        try await self.request(with: request).data
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    public func request(with request: URLRequest) async throws -> Response<Data> {
        try await withUnsafeThrowingContinuation { continuation in
            self.request(with: request) { (result: Result<Response<Data>, Error>) in
                switch result {
                case .success(let data):
                    continuation.resume(returning: data)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    public func request<T: Decodable>(with request: URLRequest, handler: @escaping @Sendable (Result<T, Error>) -> Void) {
        self.request(with: request) { (result: Result<Response<T>, Error>) in
            switch result {
            case .success(let response):
                handler(.success(response.data))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    public func request(with request: URLRequest, handler: @escaping @Sendable (Result<Data, Error>) -> Void) {
        self.request(with: request) { (result: Result<Response<Data>, Error>) in
            switch result {
            case .success(let response):
                handler(.success(response.data))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    open func request<T: Decodable>(with request: URLRequest, handler: @escaping @Sendable (Result<Response<T>, Error>) -> Void) {
        let decoder = self.decoder
        self.request(with: request) { (result: Result<Response<Data>, Error>) in
            switch result {
            case .success(let response):
                do {
                    let data = try decoder.decode(T.self, from: response.data)
                    handler(.success((response: response.response, data: data)))
                } catch {
                    handler(.failure(DataTransferError.parse(error: error)))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }

    open func request(with request: URLRequest, handler: @escaping @Sendable (Result<Response<Data>, Error>) -> Void) {
        session.dataTask(with: request) { [handler] data, response, error in
            if let error {
                return handler(.failure(DataTransferError.error(error: error)))
            }
            guard let data else {
                return handler(.failure(DataTransferError.data))
            }
            guard let response = response as? HTTPURLResponse else {
                return handler(.failure(DataTransferError.response))
            }
            guard (200 ..< 300).contains(response.statusCode) else {
                return handler(.failure(DataTransferError.status(response: response, data: data)))
            }
            handler(.success((response: response, data: data)))
        }.resume()
    }
}
