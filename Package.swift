// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LiveCastChat",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LiveCastChat",
            targets: ["LiveCastChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AgoraIO-Community/AgoraChat_iOS", from: "1.0.6")
    ],
    targets: [
        .target(
            name: "LiveCastChat",
            dependencies: []),
        .testTarget(
            name: "LiveCastChatTests",
            dependencies: ["LiveCastChat"]),
    ]
)
