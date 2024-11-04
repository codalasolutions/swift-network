//
//  DefaultDataTransferServiceTests.swift
//
//  Created by Giorgi Kratsashvili on 11/1/22.
//

import Foundation
import Testing
@testable import CSNetwork

@Suite
private struct DefaultDataTransferServiceTests {
    private struct DecodableStub: Decodable, Sendable {
        let key: String
    }

    private struct ErrorDummy: Error {}

    @Test
    func testDefaultInit() {
        let sut = DefaultDataTransferService()
        #expect(sut.session == URLSession.shared)
    }

    @Test
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncJsonSuccess() async throws {
        class URLProtocolTestStub: URLProtocolStub {
            override func stub() -> Stub {
                .init(
                    response: HTTPURLResponse(),
                    data: .init("{\"key\":\"val\"}".utf8),
                    error: nil
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        let response: DecodableStub = try await sut.request(with: dummy)

        #expect(response.key == "val")
    }

    @Test
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncJsonFailError() async {
        class URLProtocolTestStub: URLProtocolStub {
            override func stub() -> Stub {
                .init(
                    response: nil,
                    data: nil,
                    error: ErrorDummy()
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        await #expect {
            let _: DecodableStub = try await sut.request(with: dummy)
        } throws: {
            if case .error = $0 as? DataTransferError { true } else { false }
        }
    }

    @Test
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncDataSuccess() async throws {
        class URLProtocolTestStub: URLProtocolStub {
            static let data = Data("Some random data...".utf8)

            override func stub() -> Stub {
                .init(
                    response: HTTPURLResponse(),
                    data: Self.data,
                    error: nil
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        let response: Data = try await sut.request(with: dummy)

        #expect(response == URLProtocolTestStub.data)
    }

    @Test
    @available(macOS 10.15, iOS 13.0, watchOS 6.0, tvOS 13.0, *)
    func testAsyncDataFailResponse() async {
        class URLProtocolTestStub: URLProtocolStub {
            override func stub() -> Stub {
                .init(
                    response: URLResponse(),
                    data: .init(),
                    error: nil
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        await #expect {
            let _: DecodableStub = try await sut.request(with: dummy)
        } throws: {
            if case .response = $0 as? DataTransferError { true } else { false }
        }
    }

    @Test
    func testJsonSuccess() async {
        class URLProtocolTestStub: URLProtocolStub {
            override func stub() -> Stub {
                .init(
                    response: HTTPURLResponse(),
                    data: .init("{\"key\":\"value\"}".utf8),
                    error: nil
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        let result = await withUnsafeContinuation { continuation in
            sut.request(with: dummy) { (result: Result<DecodableStub, Error>) in
                let result = if case .success(let response) = result,
                                response.key == "value" {
                    true
                } else {
                    false
                }
                continuation.resume(returning: result)
            }
        }

        #expect(result)
    }

    @Test
    func testJsonFailParse() async {
        class URLProtocolTestStub: URLProtocolStub {
            override func stub() -> Stub {
                .init(
                    response: HTTPURLResponse(),
                    data: .init("Broken json data".utf8),
                    error: nil
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        let result = await withUnsafeContinuation { continuation in
            sut.request(with: dummy) { (result: Result<DecodableStub, Error>) in
                let result = if case .failure(let error) = result,
                                case .parse = error as? DataTransferError {
                    true
                } else {
                    false
                }
                continuation.resume(returning: result)
            }
        }

        #expect(result)
    }

    @Test
    func testDataSuccess() async {
        class URLProtocolTestStub: URLProtocolStub {
            static let data = Data("Some kind of data.".utf8)

            override func stub() -> Stub {
                .init(
                    response: HTTPURLResponse(),
                    data: Self.data,
                    error: nil
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        let result = await withUnsafeContinuation { continuation in
            sut.request(with: dummy) { (result: Result<Data, Error>) in
                let result = if case .success(let response) = result,
                                response == URLProtocolTestStub.data {
                    true
                } else {
                    false
                }
                continuation.resume(returning: result)
            }
        }

        #expect(result)
    }

    @Test
    func testDataFailStatus() async {
        class URLProtocolTestStub: URLProtocolStub {
            static let data = Data("{\"key\":\"value\"}".utf8)

            override func stub() -> Stub {
                .init(
                    response: HTTPURLResponse(
                        url: URLComponents().url!,
                        statusCode: 404,
                        httpVersion: nil,
                        headerFields: nil
                    ),
                    data: Self.data,
                    error: nil
                )
            }
        }

        let sut = sut(for: URLProtocolTestStub.self)

        let result = await withUnsafeContinuation { continuation in
            sut.request(with: dummy) { (result: Result<Data, Error>) in
                let result = if case .failure(let error) = result,
                                case .status(let response, let data) = error as? DataTransferError,
                                response.statusCode == 404,
                                data == URLProtocolTestStub.data {
                    true
                } else {
                    false
                }
                continuation.resume(returning: result)
            }
        }

        #expect(result)
    }

    private func sut<T: URLProtocol>(for urlProtocolType: T.Type) -> DataTransferService {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [T.self]
        let session = URLSession(configuration: config)
        return DefaultDataTransferService(session: session)
    }

    private var dummy: URLRequest { .init(url: URLComponents().url!) }
}
