//
//  RequestBuilder.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import Foundation

public protocol RequestBuilder {
    init()

    func reset() -> Self

    func set(scheme: String) -> Self
    func set(host: String) -> Self
    func set(port: Int) -> Self
    func set(path: String) -> Self
    func append(path: String) -> Self

    func set(query: [String: String]) -> Self

    func set(contentType: ContentType) -> Self
    func set(headers: [String: String]) -> Self

    func set(method: MethodType) -> Self

    func set<T: Encodable>(body: T) -> Self
    func set(body: [String: Any]) -> Self
    func set(body: Data) -> Self

    func build() throws -> URLRequest
    func build() -> URLRequest?
}
