// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OAFramework",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "OAFramework",
            targets: ["OAFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "6.0.2"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", from: "16.2.1"),
        .package(url: "https://github.com/AzureAD/microsoft-authentication-library-for-objc.git", from: "1.2.18"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "OAFramework"),
        .testTarget(
            name: "OAFrameworkTests",
            dependencies: ["OAFramework"]),
    ]
)
