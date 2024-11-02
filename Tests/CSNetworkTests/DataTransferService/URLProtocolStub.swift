//
//  URLProtocolStub.swift
//
//  Created by Giorgi Kratsashvili on 11/1/22.
//

import Foundation

class URLProtocolStub: URLProtocol {
    struct Stub {
        let response: URLResponse?
        let data: Data?
        let error: Error?
    }

    func stub() -> Stub {
        fatalError()
    }

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
        let stub = stub()
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
