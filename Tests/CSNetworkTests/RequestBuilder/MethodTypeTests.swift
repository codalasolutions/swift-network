//
//  MethodTypeTests.swift
//
//  Created by Giorgi Kratsashvili on 10/18/22.
//

import Testing
@testable import CSNetwork

@Suite
private struct MethodTypeTests {
    @Test
    private func testGet() {
        test(sut: .get)
    }

    @Test
    private func testPut() {
        test(sut: .put)
    }

    @Test
    private func testPost() {
        test(sut: .post)
    }

    @Test
    private func testPatch() {
        test(sut: .patch)
    }

    @Test
    private func testDelete() {
        test(sut: .delete)
    }

    private func test(sut: MethodType) {
        let val = sut.rawValue
        switch sut {
        case .get:    #expect(val == "GET")
        case .put:    #expect(val == "PUT")
        case .post:   #expect(val == "POST")
        case .patch:  #expect(val == "PATCH")
        case .delete: #expect(val == "DELETE")
        }
    }
}
