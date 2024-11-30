// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DataProvider",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "DataProvider",
            targets: ["DataProvider"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-http-types.git", from: "1.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "DataProvider",
            dependencies: [
                .product(name: "HTTPTypes", package: "swift-http-types"),
                .product(name: "HTTPTypesFoundation", package: "swift-http-types"),
            ]
        ),
        .testTarget(
            name: "DataProviderTests",
            dependencies: ["DataProvider"]
        ),
    ]
)

/*

 Showing Recent Issues
 product 'HTTPTypes' required by package 'dataprovider' target 'DataProvider' not found. Did you mean '.product(name: "HTTPTypes", package: "swift-http-types")'?

 */
