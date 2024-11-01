//
//  URLProtocolStub.swift
//
//  Created by Giorgi Kratsashvili on 11/1/22.
//

import Foundation
import XCTest

final class URLProtocolStub: URLProtocol {
    struct Stub {
        let response: URLResponse?
        let data: Data?
        let error: Error?
    }
    nonisolated(unsafe) static var stub: Stub?

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        respond()
    }

    override func stopLoading() {
        respond()
    }

    private func respond() {
        guard let stub = Self.stub else {
            XCTFail("Received unexpected request with no stub set")
            return
        }
        if let response = stub.response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = stub.data {
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
        if let error = stub.error {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
