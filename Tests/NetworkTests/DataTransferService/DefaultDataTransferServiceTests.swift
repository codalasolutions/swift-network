//
//  DefaultDataTransferServiceTests.swift
//
//  Created by Giorgi Kratsashvili on 11/1/22.
//

import XCTest
@testable import Network

final class DefaultDataTransferServiceTests: XCTestCase {
    private var sut: DataTransferService!
    private var stub: URLProtocolStub.Handler? {
        get { URLProtocolStub.handler }
        set { URLProtocolStub.handler = newValue }
    }
    private let request = URLRequest(url: URLComponents().url!)

    override func setUp() {
        super.setUp()
        stub = nil

        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: config)

        sut = DefaultDataTransferService(session: session)
    }

    override func tearDown() {
        super.tearDown()
        stub = nil
        sut = nil
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncDataSuccess() async throws {
        stub = { [weak self] request in
            XCTAssertEqual(request, self?.request)
            return (.init(url: request.url!, statusCode: 200, httpVersion: "1.1", headerFields: [:]),
                    .init("Some Data String".utf8),
                    nil)
        }
        let result: Data = try await sut.request(with: request)
        let string = String(decoding: result, as: UTF8.self)
        XCTAssertEqual(string, "Some Data String")
    }
}
