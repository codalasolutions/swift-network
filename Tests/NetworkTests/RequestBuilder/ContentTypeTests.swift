//
//  ContentTypeTests.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import XCTest
@testable import Network

final class ContentTypeTests: XCTestCase {
    func testJson() {
        _test(sut: .json)
    }

    func testPlain() {
        _test(sut: .plain)
    }

    func _test(sut: ContentType) {
        let val = sut.rawValue
        switch sut {
        case .json:       XCTAssertEqual(val, "application/json")
        case .urlencoded: XCTAssertEqual(val, "application/x-www-form-urlencoded")
        case .plain:      XCTAssertEqual(val, "text/plain")
        }
    }
}
