//
//  MethodTypeTests.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import XCTest
@testable import CSNetwork

final class MethodTypeTests: XCTestCase {
    func testGet() {
        _test(sut: .get)
    }

    func testPut() {
        _test(sut: .put)
    }

    func testPost() {
        _test(sut: .post)
    }

    func testPatch() {
        _test(sut: .patch)
    }

    func testDelete() {
        _test(sut: .delete)
    }

    func _test(sut: MethodType) {
        let val = sut.rawValue
        switch sut {
        case .get:    XCTAssertEqual(val, "GET")
        case .put:    XCTAssertEqual(val, "PUT")
        case .post:   XCTAssertEqual(val, "POST")
        case .patch:  XCTAssertEqual(val, "PATCH")
        case .delete: XCTAssertEqual(val, "DELETE")
        }
    }
}
