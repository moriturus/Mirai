// Copyright (c) 2022 Henrique Sasaki Yuya
// This software is released under the MIT License.
// See LICENSE file for details.

import XCTest
@testable import Mirai

// MARK: - Error

private enum Error: Swift.Error, Equatable {
    case fail
}

// MARK: - AnotherError

private enum AnotherError: Swift.Error, Equatable {
    case fail(Error)
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
        let future = Future(just: 0).map { $0 + 1 }.flatMap { Future(just: String($0)) }
        let value = try await future.get()
        XCTAssertEqual(value, "1")
    }

    func testThenGet() async throws {
        let future = Future(just: 0).flatMap { Future(just: $0 + 1) };
        let value = try await future.get()
        XCTAssertEqual(value, 1)
    }

    func testFlattenGet() async throws {
        let future = Future(just: Future(just: 0))
        let value = try await future.flatten().get()
        XCTAssertEqual(value, 0)
    }

    func testTryFutureProducerGet() async throws {
        let future = TryFuture { Result<Int, Error>.success(0) }
        let value = await future.get()
        XCTAssertEqual(value, .success(0))
    }

    func testTryFutureMapGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.success(0))
        let value = try await future.map { $0 + 1 }.get()
        XCTAssertEqual(value, .success(1))
    }

    func testTryFutureMapFailureGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.failure(.fail))
        let value = try await future.map { $0 + 1 }.get()
        XCTAssertEqual(value, .failure(.fail))
    }

    func testTryFutureMapErrorGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.failure(.fail))
        let value = try await future.mapError(AnotherError.fail).get()
        XCTAssertEqual(value, .failure(.fail(Error.fail)))
    }

    func testTryFutureMapErrorSuccessGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.success(0))
        let value = try await future.mapError(AnotherError.fail).get()
        XCTAssertEqual(value, .success(0))
    }

    func testTryFutureFlatMapGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.success(0))
        let value = try await future.flatMap { .success($0 + 1) }.get()
        XCTAssertEqual(value, .success(1))
    }

    func testTryFutureFlatMapFailureGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.failure(.fail))
        let value = try await future.flatMap { .success($0 + 1) }.get()
        XCTAssertEqual(value, .failure(.fail))
    }

    func testTryFutureFlatMapErrorGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.failure(.fail))
        let value = try await future.flatMapError { .failure(AnotherError.fail($0)) }.get()
        XCTAssertEqual(value, .failure(.fail(Error.fail)))
    }

    func testTryFutureFlatMapErrorSuccessGet() async throws {
        let future = TryFuture(just: Result<Int, Error>.success(0))
        let value = try await future.flatMapError { .failure(AnotherError.fail($0)) }.get()
        XCTAssertEqual(value, .success(0))
    }

    func testResultConvertToTryFuture() async throws {
        let result = Result<Int, Error>.success(0)
        let future = result.tryFuture
        let value = await future.get()
        XCTAssertEqual(value, .success(0))
    }
    
    func testTryFutureOk() async throws {
        let future = TryFuture(just: Result<Int, Error>.success(0))
        let value = try await future.ok()
        XCTAssertEqual(value, 0)
    }
}
