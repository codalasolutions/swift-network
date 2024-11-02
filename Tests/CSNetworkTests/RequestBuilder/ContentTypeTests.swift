//
//  ContentTypeTests.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import Testing
@testable import CSNetwork

@Suite
private struct ContentTypeTests {
    @Test
    private func testJson() {
        test(sut: .json)
    }

    @Test
    private func testUrlEncoded() {
        test(sut: .urlencoded)
    }

    @Test
    private func testPlain() {
        test(sut: .plain)
    }

    private func test(sut: ContentType) {
        let val = sut.rawValue
        switch sut {
        case .json:       #expect(val == "application/json")
        case .urlencoded: #expect(val == "application/x-www-form-urlencoded")
        case .plain:      #expect(val == "text/plain")
        }
    }
}
