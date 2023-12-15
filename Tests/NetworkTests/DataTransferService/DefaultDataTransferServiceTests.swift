//
//  DefaultDataTransferServiceTests.swift
//
//  Created by Giorgi Kratsashvili on 11/1/22.
//

import XCTest
@testable import Network

final class DefaultDataTransferServiceTests: XCTestCase {
    fileprivate struct DecodableStub: Decodable {
        let key: String
    }
    fileprivate struct ErrorDummy: Error {}

    private var sut: DataTransferService!
    private let dummy = URLRequest(url: URLComponents().url!)
    private var stub: URLProtocolStub.Stub? {
        get { URLProtocolStub.stub }
        set { URLProtocolStub.stub = newValue }
    }

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

    func testDefaultInit() {
        let stub = DefaultDataTransferService()
        XCTAssertEqual(stub.session, URLSession.shared)
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncJsonSuccess() async throws {
        stub = .init(response: HTTPURLResponse(),
                     data: .init("{\"key\":\"val\"}".utf8),
                     error: nil)

        let response: DecodableStub = try await sut.request(with: dummy)

        XCTAssertEqual(response.key, "val")
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncJsonFailError() async {
        stub = .init(response: nil, data: nil, error: ErrorDummy())
        do {
            let _: DecodableStub = try await sut.request(with: dummy)
            XCTFail()
        } catch {
            guard case .error = error as? DataTransferError
            else {
                XCTFail()
                return
            }
        }
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncDataSuccess() async throws {
        let data = Data("Some random data...".utf8)
        stub = .init(response: HTTPURLResponse(), data: data, error: nil)

        let response: Data = try await sut.request(with: dummy)

        XCTAssertEqual(response, data)
    }

    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncDataFailResponse() async {
        stub = .init(response: URLResponse(), data: .init(), error: nil)
        do {
            let _: Data = try await sut.request(with: dummy)
            XCTFail()
        } catch {
            guard case .response = error as? DataTransferError
            else {
                XCTFail()
                return
            }
        }
    }

    func testJsonSuccess() {
        stub = .init(response: HTTPURLResponse(),
                     data: .init("{\"key\":\"value\"}".utf8),
                     error: nil)

        let ex = expectation(description: "")

        sut.request(with: dummy) { (result: Result<DecodableStub, Error>) in
            if case .success(let response) = result,
               response.key == "value" {
                ex.fulfill()
            }
        }

        wait(for: [ex], timeout: 0.1)
    }

    func testJsonFailParse() {
        stub = .init(response: HTTPURLResponse(),
                     data: .init("Broken json data".utf8),
                     error: nil)

        let ex = expectation(description: "")

        sut.request(with: dummy) { (result: Result<DecodableStub, Error>) in
            if case .failure(let error) = result,
               case .parse = error as? DataTransferError {
                ex.fulfill()
            }
        }

        wait(for: [ex], timeout: 0.1)
    }

    func testDataSuccess() {
        let data = Data("Some kind of data.".utf8)
        stub = .init(response: HTTPURLResponse(),
                     data: data,
                     error: nil)

        let ex = expectation(description: "")

        sut.request(with: dummy) { (result: Result<Data, Error>) in
            if case .success(let response) = result,
               response == data {
                ex.fulfill()
            }
        }

        wait(for: [ex], timeout: 0.1)
    }

    func testDataFailStatus() {
        let _data = Data("{\"key\":\"value\"}".utf8)
        stub = .init(response: HTTPURLResponse(url: URLComponents().url!,
                                               statusCode: 404,
                                               httpVersion: nil,
                                               headerFields: nil),
                     data: _data,
                     error: nil)

        let ex = expectation(description: "")

        sut.request(with: dummy) { (result: Result<Data, Error>) in
            if case .failure(let error) = result,
               case .status(let response, let data) = error as? DataTransferError,
               response.statusCode == 404, data == _data {
                ex.fulfill()
            }
        }

        wait(for: [ex], timeout: 0.1)
    }
}
