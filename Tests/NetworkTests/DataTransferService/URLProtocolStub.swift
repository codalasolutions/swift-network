//
//  URLProtocolStub.swift
//
//  Created by Giorgi Kratsashvili on 11/1/22.
//

import Foundation
import XCTest

final class URLProtocolStub: URLProtocol {
    typealias Handler = (URLRequest) -> (HTTPURLResponse?, Data?, Error?)
    static var handler: Handler?

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
        guard let handler = Self.handler else {
            XCTFail("Received unexpected request with no handler set")
            return
        }
        let (response, data, error) = handler(request)
        if let response = response {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
        if let error = error {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }
}
