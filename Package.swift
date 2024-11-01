// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "CSNetwork",
    products: [
        .library(
            name: "CSNetwork",
            targets: ["CSNetwork"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "CSNetwork",
            dependencies: [],
            swiftSettings: [.swiftLanguageMode(.v6)]),
        .testTarget(
            name: "CSNetworkTests",
            dependencies: ["CSNetwork"],
            swiftSettings: [.swiftLanguageMode(.v6)]),
    ]
)
