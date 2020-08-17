// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TgBotSDK",
    products: [
        .library(
            name: "TgBotSDK",
            targets: ["TgBotSDK"]),
    ],
    dependencies: [
        .package(url: "https://github.com/dmoroz0v/ChatBotSDK.git", .exect("0.0.2")),
    ],
    targets: [
        .target(
            name: "TgBotSDK",
            dependencies: [
                "ChatBotSDK",
            ]
        ),
    ]
)
