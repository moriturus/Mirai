// Copyright (c) 2022 Henrique Sasaki Yuya
// This software is released under the MIT License.
// See LICENSE file for details.

import Foundation

// MARK: - TryFutureProtocol

public protocol TryFutureProtocol: FutureProtocol where Output == Result<OK, Err> {
    associatedtype OK
    associatedtype Err: Error

    func ok() async throws -> OK
}

public extension TryFutureProtocol where Output == Result<OK, Err> {
    func ok() async throws -> OK {
        try await self.get().get()
    }
}

public extension FutureProtocol {
    func map<S, F, U>(_ transform: @escaping (S) async -> U) -> MapSuccess<Self, S, F, U>
        where Self.Output == Result<S, F>, F: Error {
        MapSuccess(self, transform)
    }

    func mapError<S, F, E>(_ transform: @escaping (F) async -> E) -> MapError<Self, S, F, E>
        where Self.Output == Result<S, F>, F: Error, E: Error {
        MapError(self, transform)
    }

    func flatMap<S, F, U>(_ transform: @escaping (S) async -> Result<U, F>) -> FlatMapSuccess<Self, S, F, U>
        where Self.Output == Result<S, F>, F: Error {
        FlatMapSuccess(self, transform)
    }

    func flatMapError<S, F, E>(_ transform: @escaping (F) async -> Result<S, E>) -> FlatMapError<Self, S, F, E>
        where Self.Output == Result<S, F>, F: Error, E: Error {
        FlatMapError(self, transform)
    }
}

// MARK: - MapSuccess

public struct MapSuccess<P, S, F, T>: TryFutureProtocol where P: FutureProtocol,
    P.Output == Result<S, F>, F: Error {
    public typealias OK = T
    public typealias Err = F

    private let predecessor: P
    private let transform: (S) async -> T

    public init(_ predecessor: P, _ transform: @escaping (S) async -> T) {
        self.predecessor = predecessor
        self.transform = transform
    }

    public func get() async throws -> Result<T, F> {
        let pr = try await self.predecessor.get()
        switch pr {
        case .success(let s):
            return .success(await self.transform(s))
        case .failure(let f):
            return .failure(f)
        }
    }
}

// MARK: - MapError

public struct MapError<P, S, F, E>: TryFutureProtocol where P: FutureProtocol,
    P.Output == Result<S, F>, F: Error,
    E: Error {
    public typealias OK = S
    public typealias Err = E

    private let predecessor: P
    private let transform: (F) async -> E

    public init(_ predecessor: P, _ transform: @escaping (F) async -> E) {
        self.predecessor = predecessor
        self.transform = transform
    }

    public func get() async throws -> Result<S, E> {
        let pr = try await self.predecessor.get()
        switch pr {
        case .success(let s):
            return .success(s)
        case .failure(let f):
            return .failure(await self.transform(f))
        }
    }
}

// MARK: - FlatMapSuccess

public struct FlatMapSuccess<P, S, F, T>: TryFutureProtocol where P: FutureProtocol,
    P.Output == Result<S, F>, F: Error {
    public typealias OK = T
    public typealias Err = F

    private let predecessor: P
    private let transform: (S) async -> Result<T, F>

    public init(_ predecessor: P, _ transform: @escaping (S) async -> Result<T, F>) {
        self.predecessor = predecessor
        self.transform = transform
    }

    public func get() async throws -> Result<T, F> {
        let pr = try await self.predecessor.get()
        switch pr {
        case .success(let s):
            return await self.transform(s)
        case .failure(let f):
            return .failure(f)
        }
    }
}

// MARK: - FlatMapError

public struct FlatMapError<P, S, F, E>: TryFutureProtocol where P: FutureProtocol,
    P.Output == Result<S, F>, F: Error,
    E: Error {
    public typealias OK = S
    public typealias Err = E

    private let predecessor: P
    private let transform: (F) async -> Result<S, E>

    public init(_ predecessor: P, _ transform: @escaping (F) async -> Result<S, E>) {
        self.predecessor = predecessor
        self.transform = transform
    }

    public func get() async throws -> Result<S, E> {
        let pr = try await self.predecessor.get()
        switch pr {
        case .success(let s):
            return .success(s)
        case .failure(let f):
            return await self.transform(f)
        }
    }
}

// MARK: - TryFuture

public struct TryFuture<S, E>: TryFutureProtocol where E: Error {
    public typealias OK = S
    public typealias Err = E

    private let producer: () async -> Result<S, E>

    public init(producer: @escaping () async -> Result<S, E>) {
        self.producer = producer
    }

    public init(just result: Result<S, E>) {
        self.init(producer: { result })
    }

    public func get() async -> Result<S, E> {
        await self.producer()
    }
}

public extension Result {
    var tryFuture: TryFuture<Success, Failure> {
        TryFuture<Success, Failure> {
            self
        }
    }
}
