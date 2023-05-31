//
//  DataTransferErrorTests.swift
//
//  Created by Giorgi Kratsashvili on 5/31/23.
//

import XCTest
@testable import Network

final class DataTransferErrorTests: XCTestCase {
    private let error: Error = DummyError()

    func testLocalizedDescriptionData() {
        let sut: DataTransferError = .data
        XCTAssertEqual(sut.localizedDescription,
                       "\(sut.prefix)\(sut.separator)data")
    }

    func testLocalizedDescriptionResponse() {
        let sut: DataTransferError = .response
        XCTAssertEqual(sut.localizedDescription,
                       "\(sut.prefix)\(sut.separator)response")
    }

    func testLocalizedDescriptionStatus() {
        let code = 404
        let sut: DataTransferError = .status(code: code)
        XCTAssertEqual(sut.localizedDescription,
                       "\(sut.prefix)\(sut.separator)status\(sut.separator)\(code)")
    }

    func testLocalizedDescriptionError() {
        let sut: DataTransferError = .error(error: error)
        XCTAssertEqual(sut.localizedDescription,
                       "\(sut.prefix)\(sut.separator)error\(sut.separator)\(error.localizedDescription)")
    }

    func testLocalizedDescriptionParse() {
        let sut: DataTransferError = .parse(error: error)
        XCTAssertEqual(sut.localizedDescription,
                       "\(sut.prefix)\(sut.separator)parse\(sut.separator)\(error.localizedDescription)")
    }
}

fileprivate struct DummyError: Error, LocalizedError {
    let errorDescription: String

    init(errorDescription: String = "description") {
        self.errorDescription = errorDescription
    }
}
