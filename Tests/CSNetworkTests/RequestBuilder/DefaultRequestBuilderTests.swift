//
//  DefaultRequestBuilderTests.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import Foundation
import Testing
@testable import CSNetwork

@Suite
private struct DefaultRequestBuilderTests {
    private var sut: RequestBuilder = DefaultRequestBuilder()

    @Test
    func testSchemeHostPortPathParams() throws {
        let request: URLRequest = try sut
            .set(scheme: "https")
            .set(host: "www.example.com")
            .set(port: 8080)
            .set(path: "/some")
            .append(path: "/path")
            .set(query: [("key1", "val1")])
            .append(query: ("key2", "val2"))
            .set(method: .get)
            .build()

        #expect(request.httpMethod == "GET")

        let extectation = "https://www.example.com:8080/some/path?key1=val1&key2=val2"
        let actual = request.url?.absoluteString

        #expect(actual == extectation)
    }

    @Test
    func testHeaders() throws {
        let request: URLRequest = try sut
            .set(headers: ["Key1": "Val1", "Key2": "Val2"])
            .set(method: .put)
            .set(host: "www.something.org")
            .set(scheme: "http")
            .build()

        #expect(request.httpMethod == "PUT")
        #expect(request.allHTTPHeaderFields?["Key1"] == "Val1")
        #expect(request.allHTTPHeaderFields?["Key2"] == "Val2")
    }

    @Test
    func testBodyEncodableContentTypeJson() throws {
        struct Body: Codable {
            let key: String
        }

        let request: URLRequest = try sut
            .set(method: .post)
            .set(contentType: .json)
            .set(scheme: "https")
            .set(host: "www.anything.gov.ge")
            .set(body: Body(key: "val"))
            .build()

        #expect(request.httpMethod == "POST")
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")

        let extectation = "{\"key\":\"val\"}"
        let actual = String(decoding: request.httpBody ?? .init(), as: UTF8.self)
        #expect(actual == extectation)
    }

    @Test
    func testBodyWithArray() throws {
        struct Body: Encodable {
            let key1 = "val1"
            let key2 = ["val", "val"]
        }

        let request: URLRequest = try sut
            .set(contentType: .json)
            .set(body: Body())
            .set(scheme: "http")
            .set(host: "www.whatever.ge")
            .set(method: .patch)
            .build()

        #expect(request.httpMethod == "PATCH")

        let extectation1 = "{\"key1\":\"val1\",\"key2\":[\"val\",\"val\"]}"
        let extectation2 = "{\"key2\":[\"val\",\"val\"],\"key1\":\"val1\"}"
        let actual = String(decoding: request.httpBody ?? .init(), as: UTF8.self)

        #expect(actual == extectation1 || actual == extectation2)
    }

    @Test
    func testBodyDataContentTypePlain() throws {
        let request: URLRequest = try sut
            .set(body: Data("Some Data".utf8))
            .set(host: "www.some.company.name.com")
            .set(method: .delete)
            .set(scheme: "https")
            .set(contentType: .plain)
            .build()

        #expect(request.httpMethod == "DELETE")
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "text/plain")

        let actual = String(decoding: request.httpBody ?? .init(), as: UTF8.self)
        #expect(actual == "Some Data")
    }

    @Test
    func testBodyDataContentTypeUrlencoded() throws {
        let request: URLRequest = try sut
            .set(scheme: "https")
            .set(host: "www.example.com")
            .set(method: .post)
            .set(contentType: .urlencoded)
            .set(body: [("key1", "val1"), ("key2", "val2")])
            .build()

        #expect(request.httpMethod == "POST")

        let extectation1 = "key1=val1&key2=val2"
        let extectation2 = "key2=val2&key1=val1"
        let actual = String(decoding: request.httpBody ?? .init(), as: UTF8.self)

        #expect(actual == extectation1 || actual == extectation2)
    }

    @Test
    func testFullFunctionality() throws {
        let request: URLRequest = try sut
            .set(method: .put)
            .set(contentType: .json)
            .set(scheme: "http")
            .set(host: "www.full.functionality.com")
            .set(path: "/some")
            .append(path: "/random")
            .append(path: "/path")
            .append(query: ("key", "val"))
            .set(headers: ["key": "val"])
            .set(body: ["key": "val"])
            .build()

        #expect(request.url?.absoluteString == "http://www.full.functionality.com/some/random/path?key=val")
        #expect(request.httpMethod == "PUT")
        #expect(request.allHTTPHeaderFields?["Content-Type"] == "application/json")
        #expect(request.allHTTPHeaderFields?["key"] == "val")
        #expect(String(decoding: request.httpBody ?? .init(), as: UTF8.self) == "{\"key\":\"val\"}")
    }

    @Test
    func testReset() throws {
        let defaultRequest: URLRequest = try sut.build()

        #expect(defaultRequest != nil)

        let _: URLRequest = try sut
            .set(headers: ["key": "val"])
            .set(contentType: .json)
            .set(body: ["key": "val"])
            .set(query: [("key", "val")])
            .set(path: "/some/path")
            .set(host: "www.reset.com")
            .set(scheme: "http")
            .set(method: .put)
            .build()

        let requestAfterReset: URLRequest = try sut
            .reset()
            .build()

        #expect(defaultRequest == requestAfterReset)
    }

    @Test
    func testBuildFail() {
        #expect(sut.build() != nil)

        let builder = sut
            .reset()
            .set(path: "//some/broken/path")
            .set(scheme: "https")

        #expect(throws: RequestBuilderError.invalid) {
            try builder.build()
        }
    }
}
