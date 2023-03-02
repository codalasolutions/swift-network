//
//  DefaultRequestBuilder.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import Foundation

public class DefaultRequestBuilder: RequestBuilder {
    private lazy var components = defaultComponents
    private lazy var request = defaultRequest
    private var defaultComponents: URLComponents { .init() }
    private var defaultRequest: URLRequest { .init(url: defaultComponents.url!) }

    public required init() {}

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

    public func set(query: [String: String]) -> Self {
        components.queryItems = []
        query.forEach {
            components.queryItems?.append(.init(name: $0, value: $1))
        }
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

    public func set<T: Encodable>(body: T) -> Self {
        let body = try? JSONEncoder().encode(body)
        request.httpBody = body
        return self
    }

    public func set(body: [String: Any]) -> Self {
        let body = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = body
        return self
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
