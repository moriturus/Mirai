// Copyright (c) 2022 Henrique Yuya Sasaki
// This software is released under the MIT License.
// See LICENSE file for details.

// MARK: - FutureProtocol

public protocol FutureProtocol {
    associatedtype Output
    
    init(just value: Output)
    init(provider: @escaping () async throws -> Output)
    func get() async throws -> Self.Output
    func map<U>(_ transform: @escaping (Output) async throws -> U) -> Self where Self.Output == U
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
    
    public func map<U>(_ transform: @escaping (Output) async throws -> U) -> Future<U> {
        Future<U> {
            try await transform(try await self.get())
        }
    }
}
