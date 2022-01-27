// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hsdoc",
    platforms: [.macOS(.v11)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HSDocKit",
            targets: ["HSDocKit"]),
        .executable(
            name: "hsdoc",
            targets: ["hsdoc"]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-parsing.git", from: "0.5.0"),
        .package(url: "https://github.com/randomeizer/swift-parsing-async.git", branch: "main"),
        .package(url: "https://github.com/pointfreeco/swift-nonempty.git", from: "0.4.0"),
        .package(url: "https://github.com/Quick/Nimble.git", from: "9.0.0"),
        .package(url: "https://github.com/Quick/Quick.git", from: "3.0.1"),
        .package(url: "https://github.com/pointfreeco/swift-custom-dump", from: "0.3.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "HSDocKit",
            dependencies: [
                .product(name: "Parsing", package: "swift-parsing"),
                .product(name: "ParsingAsync", package: "swift-parsing-async"),
                .product(name: "NonEmpty", package: "swift-nonempty"),
            ]),
        .testTarget(
            name: "HSDocKitTests",
            dependencies: [
                "HSDocKit", "Nimble", "Quick",
                .product(name: "CustomDump", package: "swift-custom-dump"),
            ]),
        .executableTarget(name: "hsdoc",
                dependencies: [
                    "HSDocKit"
                ]),
    ]
)
