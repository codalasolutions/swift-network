//
//  DefaultRequestBuilderTests.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import XCTest
@testable import Network

final class DefaultRequestBuilderTests: XCTestCase {
    private var sut: RequestBuilder!

    override func setUp() {
        super.setUp()
        sut = DefaultRequestBuilder()
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
    }

    func testSchemeHostPathParams() {
        let request = sut
            .set(scheme: "https")
            .set(host: "www.example.com")
            .set(path: "/some/path")
            .set(query: ["key1": "val1", "key2": "val2"])
            .set(method: .get)
            .build()

        XCTAssertEqual(request?.httpMethod, "GET")

        let extectation = "https://www.example.com/some/path?"
        let extectation1 = extectation + "key1=val1&key2=val2"
        let extectation2 = extectation + "key2=val2&key1=val1"
        let actual = request?.url?.absoluteString

        XCTAssertTrue(actual == extectation1 || actual == extectation2)
    }

    func testHeaders() {
        let request = sut
            .set(scheme: "http")
            .set(host: "www.example.com")
            .set(method: .put)
            .set(headers: ["Key1": "Val1", "Key2": "Val2"])
            .build()

        XCTAssertEqual(request?.httpMethod, "PUT")
        XCTAssertEqual(request?.allHTTPHeaderFields?["Key1"], "Val1")
        XCTAssertEqual(request?.allHTTPHeaderFields?["Key2"], "Val2")
    }

    func testBodyEncodableContentTypeJson() {
        struct Body: Codable {
            let key: String
        }

        let request = sut
            .set(scheme: "https")
            .set(host: "www.example.com")
            .set(method: .post)
            .set(contentType: .json)
            .set(body: Body(key: "val"))
            .build()

        XCTAssertEqual(request?.httpMethod, "POST")
        XCTAssertEqual(request?.allHTTPHeaderFields?["Content-Type"], "application/json")

        let extectation = "{\"key\":\"val\"}"
        let actual = String(decoding: request?.httpBody ?? .init(), as: UTF8.self)
        XCTAssertEqual(actual, extectation)
    }

    func testBodyDictionary() {
        let request = sut
            .set(scheme: "http")
            .set(host: "www.example.com")
            .set(method: .patch)
            .set(contentType: .json)
            .set(body: [
                "key1": "val1",
                "key2": ["val", "val"]
            ])
            .build()

        XCTAssertEqual(request?.httpMethod, "PATCH")

        let extectation1 = "{\"key1\":\"val1\",\"key2\":[\"val\",\"val\"]}"
        let extectation2 = "{\"key2\":[\"val\",\"val\"],\"key1\":\"val1\"}"
        let actual = String(decoding: request?.httpBody ?? .init(), as: UTF8.self)

        XCTAssertTrue(actual == extectation1 || actual == extectation2)
    }

    func testBodyDataContentTypePlain() {
        let request = sut
            .set(scheme: "https")
            .set(host: "www.example.com")
            .set(method: .delete)
            .set(contentType: .plain)
            .set(body: Data("Some Data".utf8))
            .build()

        XCTAssertEqual(request?.httpMethod, "DELETE")
        XCTAssertEqual(request?.allHTTPHeaderFields?["Content-Type"], "text/plain")

        let actual = String(decoding: request?.httpBody ?? .init(), as: UTF8.self)
        XCTAssertEqual(actual, "Some Data")
    }
}
