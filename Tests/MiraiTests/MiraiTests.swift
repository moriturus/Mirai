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

    func testFutureProvideMapGet() async throws {
        let future = Future<Int> { 0 }
        let value = try await future.map(String.init).get()
        XCTAssertEqual(value, "0")
    }

    func testFutureProvideMapFailGet() async throws {
        let future = Future(just: 0)
        do {
            let newFuture = future.map { _ -> Int in throw Error.fail }
            let _ = try await newFuture.get()
        } catch let e {
            XCTAssertEqual(Error.fail, e as! Error)
        }
    }

    func testMapIntoFuture() async throws {
        let future = Future(just: 0).map { $0 + 1 }.map(String.init).intoFuture()
        let value = try await future.get()
        XCTAssertEqual(value, "1")
    }
    
    func testMapThenGet() async throws {
        let future = Future(just: 0).map { $0 + 1 }.then { Future(just: String($0)) }
        let value = try await future.get()
        XCTAssertEqual(value, "1")
    }

    func testThenGet() async throws {
        let future = Future(just: 0).then { Future(just: $0 + 1) };
        let value = try await future.get()
        XCTAssertEqual(value, 1)
    }

    func testFlattenGet() async throws {
        let future = Future(just: Future(just: 0))
        let value = try await future.flatten().get()
        XCTAssertEqual(value, 0)
    }
}
