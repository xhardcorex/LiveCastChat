// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LiveCastChat",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "LiveCastChat",
            targets: ["LiveCastChat"]),
    ],
    dependencies: [
        .package(url: "https://github.com/AgoraIO-Community/AgoraChat_iOS", from: "1.0.6"),
        .package(url: "https://github.com/kirualex/SwiftyGif", from: "5.4.3"),
        .package(url: "https://github.com/Alamofire/AlamofireImage", from: "4.2.0"),
        .package(url: "https://github.com/Giphy/giphy-ios-sdk", from: "2.1.3"),
        .package(url: "https://github.com/relatedcode/ProgressHUD", from: "13.6.1"),
        .package(url: "https://github.com/lojals/ReactionButton", branch: "main")
    ],
    targets: [
        .target(
            name: "LiveCastChat",
            dependencies: [.product(name: "AgoraChat", package: "AgoraChat_iOS"),
                           .product(name: "SwiftyGif", package: "SwiftyGif"),
                           .product(name: "AlamofireImage", package: "AlamofireImage"),
                           .product(name: "GiphyUISDK", package: "giphy-ios-sdk"),
                           .product(name: "ProgressHUD", package: "ProgressHUD"),
                           .product(name: "ReactionButton", package: "ReactionButton")],
            path: "Sources"),
        .testTarget(
            name: "LiveCastChatTests",
            dependencies: ["LiveCastChat"]),
    ]
)
