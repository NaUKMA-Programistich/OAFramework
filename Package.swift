// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "OAFramework",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "OAFramework",
            targets: ["OAFramework"]),
    ],
    dependencies: [
        .package(url: "https://github.com/google/GoogleSignIn-iOS.git", from: "6.0.2"),
        .package(url: "https://github.com/facebook/facebook-ios-sdk.git", from: "16.2.1"),
        .package(url: "https://github.com/AzureAD/microsoft-authentication-library-for-objc.git", from: "1.2.18"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "OAFramework",
            dependencies: [
                .product(name: "GoogleSignIn", package: "GoogleSignIn-iOS"),
                .product(name: "Logging", package: "swift-log")
            ]
        ),
    ]
)
