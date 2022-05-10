# Mirai

[![codecov](https://codecov.io/gh/moriturus/Mirai/branch/main/graph/badge.svg?token=EP7BOYQ464)](https://codecov.io/gh/moriturus/Mirai)

`Mirai` provides Rust-styled `Future`.

## Installation

Please use the `Swift Package Manager`.

```swift
dependencies: [
    .package(url: "https://github.com/moriturus/Mirai.git", .upToNextMajor(from: "1.0.0"))
]
```

## Usage

```swift
let future = Future<Int>(just: 0)

do {
    let value = try await future.get()
} catch {
    // handle errors
}
```

or

```swift
func provideSomeValue() async -> Int {
    0
}

let futureByAsyncFunction = Future(provider: provideSomeValue)

do {
    let value = try await futureByAsyncFunction.get()
} catch {
    // handle errors.
}
```

## License

This software is released under the MIT License.  
See LICENSE file for details.
