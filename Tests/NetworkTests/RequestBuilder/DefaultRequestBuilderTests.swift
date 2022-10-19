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
            .set(headers: ["Key1": "Val1", "Key2": "Val2"])
            .set(method: .put)
            .set(host: "www.something.org")
            .set(scheme: "http")
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
            .set(method: .post)
            .set(contentType: .json)
            .set(scheme: "https")
            .set(host: "www.anything.gov.ge")
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
            .set(contentType: .json)
            .set(body: [
                "key1": "val1",
                "key2": ["val", "val"]
            ])
            .set(scheme: "http")
            .set(host: "www.whatever.ge")
            .set(method: .patch)
            .build()

        XCTAssertEqual(request?.httpMethod, "PATCH")

        let extectation1 = "{\"key1\":\"val1\",\"key2\":[\"val\",\"val\"]}"
        let extectation2 = "{\"key2\":[\"val\",\"val\"],\"key1\":\"val1\"}"
        let actual = String(decoding: request?.httpBody ?? .init(), as: UTF8.self)

        XCTAssertTrue(actual == extectation1 || actual == extectation2)
    }

    func testBodyDataContentTypePlain() {
        let request = sut
            .set(body: Data("Some Data".utf8))
            .set(host: "www.some.company.name.com")
            .set(method: .delete)
            .set(scheme: "https")
            .set(contentType: .plain)
            .build()

        XCTAssertEqual(request?.httpMethod, "DELETE")
        XCTAssertEqual(request?.allHTTPHeaderFields?["Content-Type"], "text/plain")

        let actual = String(decoding: request?.httpBody ?? .init(), as: UTF8.self)
        XCTAssertEqual(actual, "Some Data")
    }

    func testFullFunctionality() {
        let request = sut
            .set(method: .put)
            .set(contentType: .json)
            .set(scheme: "http")
            .set(host: "www.full.functionality.com")
            .set(path: "/some/random/path")
            .set(query: ["key": "val"])
            .set(headers: ["key": "val"])
            .set(body: ["key": "val"])
            .build()

        XCTAssertEqual(request?.url?.absoluteString, "http://www.full.functionality.com/some/random/path?key=val")
        XCTAssertEqual(request?.httpMethod, "PUT")
        XCTAssertEqual(request?.allHTTPHeaderFields?["Content-Type"], "application/json")
        XCTAssertEqual(request?.allHTTPHeaderFields?["key"], "val")
        XCTAssertEqual(String(decoding: request?.httpBody ?? .init(), as: UTF8.self), "{\"key\":\"val\"}")
    }

    func testReset() {
        let defaultRequest = sut.build()

        XCTAssertNotNil(defaultRequest)

        let _ = sut
            .set(headers: ["key": "val"])
            .set(contentType: .json)
            .set(body: ["key": "val"])
            .set(query: ["key": "val"])
            .set(path: "/some/path")
            .set(host: "www.reset.com")
            .set(scheme: "http")
            .set(method: .put)
            .build()

        let requestAfterReset = sut
            .reset()
            .build()

        XCTAssertEqual(defaultRequest, requestAfterReset)
    }

    func testBuildFail() {
        XCTAssertNotNil(sut.build())

        let request = sut
            .reset()
            .set(path: "//some/broken/path")
            .set(scheme: "https")
            .build()

        XCTAssertNil(request)
    }
}
