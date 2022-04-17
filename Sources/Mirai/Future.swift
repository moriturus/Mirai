// Copyright (c) 2022 Henrique Yuya Sasaki
// This software is released under the MIT License.
// See LICENSE file for details.

// MARK: - FutureProtocol

public protocol FutureProtocol {
    associatedtype Output

    func get() async throws -> Self.Output
}

public extension FutureProtocol {
    func map<U>(_ transform: @escaping (Output) async throws -> U) -> Map<Self, U> {
        Map(self, transform)
    }

    func then<F>(_ transform: @escaping (Output) async throws -> F) -> Then<Self, F> where F: FutureProtocol {
        Then(self, transform)
    }

    func flatten() -> Flatten<Self> where Self.Output: FutureProtocol {
        Flatten(self)
    }

    func intoFuture() -> Future<Output> {
        Future<Output> {
            try await self.get()
        }
    }
}

// MARK: - Map

public struct Map<P, T>: FutureProtocol where P: FutureProtocol {
    public typealias Output = T

    private let predecessor: P
    private let transform: (P.Output) async throws -> Output

    public init(_ predecessor: P, _ transform: @escaping (P.Output) async throws -> Output) {
        self.predecessor = predecessor
        self.transform = transform
    }

    public func get() async throws -> Output {
        try await self.transform(try self.predecessor.get())
    }
}

// MARK: - Then

public struct Then<P, F>: FutureProtocol where P: FutureProtocol, F: FutureProtocol {
    public typealias Output = F.Output

    private let predecessor: P
    private let transform: (P.Output) async throws -> F

    public init(_ predecessor: P, _ transform: @escaping (P.Output) async throws -> F) {
        self.predecessor = predecessor
        self.transform = transform
    }

    public func get() async throws -> Output {
        try await self.transform(try self.predecessor.get()).get()
    }
}

// MARK: - Flatten

public struct Flatten<P>: FutureProtocol where P: FutureProtocol, P.Output: FutureProtocol {
    public typealias Output = P.Output.Output

    private let predecessor: P

    public init(_ predecessor: P) {
        self.predecessor = predecessor
    }

    public func get() async throws -> Output {
        try await self.predecessor.get().get()
    }
}

// MARK: - Future

public struct Future<T>: FutureProtocol {
    public typealias Output = T

    private let provider: () async throws -> Output

    public init(just value: T) {
        self.init(provider: { value })
    }

    public init(provider: @escaping () async throws -> Output) {
        self.provider = provider
    }

    public func get() async throws -> Output {
        try await self.provider()
    }
}
