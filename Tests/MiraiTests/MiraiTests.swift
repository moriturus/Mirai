// Copyright (c) 2022 Henrique Yuya Sasaki
// This software is released under the MIT License.
// See LICENSE file for details.

import XCTest
@testable import Mirai

// MARK: - Error

private enum Error: Swift.Error {
    case fail
}

// MARK: - MiraiTests

final class MiraiTests: XCTestCase {
    func testFutureJustGet() async throws {
        let future = Future(just: 0)
        let value = try await future.get()
        XCTAssertEqual(value, 0)
    }

    func testFutureProviderGet() async throws {
        let future = Future<Int> { 0 }
        let value = try await future.get()
        XCTAssertEqual(value, 0)
    }

    func testFutureInitproviderFail() async throws {
        let future = Future<Int> { throw Error.fail }

        do {
            let _ = try await future.get()
        } catch let e {
            XCTAssertEqual(Error.fail, e as! Error)
        }
    }

    func testFutureJustMapGet() async throws {
        let future = Future(just: 0)
        let value = try await future.map(String.init).get()
        XCTAssertEqual(value, "0")
    }

    func testFutureprovideMapGet() async throws {
        let future = Future<Int> { 0 }
        let value = try await future.map(String.init).get()
        XCTAssertEqual(value, "0")
    }
}
