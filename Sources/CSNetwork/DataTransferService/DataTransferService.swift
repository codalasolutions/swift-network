//
//  DataTransferService.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

import Foundation

public protocol DataTransferService {
    typealias Response<T> = (response: HTTPURLResponse, data: T)

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func request<T: Decodable & Sendable>(with request: URLRequest) async throws -> T
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func request<T: Decodable & Sendable>(with request: URLRequest) async throws -> Response<T>

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func request(with request: URLRequest) async throws -> Data
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func request(with request: URLRequest) async throws -> Response<Data>

    func request<T: Decodable>(with request: URLRequest, handler: @escaping @Sendable (Result<T, Error>) -> Void)
    func request<T: Decodable>(with request: URLRequest, handler: @escaping @Sendable (Result<Response<T>, Error>) -> Void)

    func request(with request: URLRequest, handler: @escaping @Sendable (Result<Data, Error>) -> Void)
    func request(with request: URLRequest, handler: @escaping @Sendable (Result<Response<Data>, Error>) -> Void)
}
