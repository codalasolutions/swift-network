//
//  DefaultRequestBuilder.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import Foundation

public class DefaultRequestBuilder: RequestBuilder {
    private let encoder: JSONEncoder
    private lazy var components = defaultComponents
    private lazy var request = defaultRequest
    private var defaultComponents: URLComponents { .init() }
    private var defaultRequest: URLRequest { .init(url: defaultComponents.url!) }

    public init(encoder: JSONEncoder = .init()) {
        self.encoder = encoder
    }

    public func reset() -> Self {
        components = defaultComponents
        request = defaultRequest
        return self
    }

    public func set(scheme: String) -> Self {
        components.scheme = scheme
        return self
    }

    public func set(host: String) -> Self {
        components.host = host
        return self
    }

    public func set(port: Int) -> Self {
        components.port = port
        return self
    }

    public func set(path: String) -> Self {
        components.path = path
        return self
    }

    public func append(path: String) -> Self {
        components.path.append(path)
        return self
    }

    public func set(query: [(String, String)]) -> Self {
        components.queryItems = .init()
        query.forEach {
            components.queryItems?.append(.init(name: $0, value: $1))
        }
        return self
    }

    public func append(query: (String, String)) -> Self {
        if components.queryItems == nil {
            components.queryItems = .init()
        }
        components.queryItems?.append(.init(name: query.0, value: query.1))
        return self
    }

    public func set(contentType: ContentType) -> Self {
        request.setValue(contentType.rawValue, forHTTPHeaderField: "Content-Type")
        return self
    }

    public func set(headers: [String: String]) -> Self {
        headers.forEach {
            request.setValue($1, forHTTPHeaderField: $0)
        }
        return self
    }

    public func set(method: MethodType) -> Self {
        request.httpMethod = method.rawValue
        return self
    }

    public func set<T: Encodable>(body: T) throws -> Self {
        let body = try encoder.encode(body)
        request.httpBody = body
        return self
    }

    public func set(body: [(String, String)]) throws -> Self {
        var components = defaultComponents
        components.queryItems = .init()
        body.forEach {
            components.queryItems?.append(.init(name: $0, value: $1))
        }
        if let body = components.query?.data(using: .utf8) {
            return set(body: body)
        }
        throw RequestBuilderError.invalid
    }

    public func set(body: Data) -> Self {
        request.httpBody = body
        return self
    }

    public func build() throws -> URLRequest {
        if let request = build() {
            return request
        }
        throw RequestBuilderError.invalid
    }

    public func build() -> URLRequest? {
        if let url = components.url {
            request.url = url
            return request
        }
        return nil
    }
}

fileprivate extension URLComponents {
    mutating func set(query: [(String, String)]) {
        queryItems = .init()
        query.forEach {
            queryItems?.append(.init(name: $0, value: $1))
        }
    }
}
