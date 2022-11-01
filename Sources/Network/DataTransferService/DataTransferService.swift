//
//  DataTransferService.swift
//
//  Created by Giorgi Kratsashvili on 10/31/22.
//

import Foundation

public protocol DataTransferService {
    typealias Response<T> = (response: HTTPURLResponse, data: T)

    init()
    init(session: URLSession)

    @available(iOS 13.0, *)
    func request<T: Decodable>(with request: URLRequest) async throws -> T
    @available(iOS 13.0, *)
    func request<T: Decodable>(with request: URLRequest) async throws -> Response<T>

    @available(iOS 13.0, *)
    func request(with request: URLRequest) async throws -> Data
    @available(iOS 13.0, *)
    func request(with request: URLRequest) async throws -> Response<Data>

    func request<T: Decodable>(with request: URLRequest, handler: @escaping (Result<T, Error>) -> Void)
    func request<T: Decodable>(with request: URLRequest, handler: @escaping (Result<Response<T>, Error>) -> Void)

    func request(with request: URLRequest, handler: @escaping (Result<Data, Error>) -> Void)
    func request(with request: URLRequest, handler: @escaping (Result<Response<Data>, Error>) -> Void)
}
