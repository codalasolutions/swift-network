// swift-tools-version: 5.8

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
            dependencies: []),
        .testTarget(
            name: "CSNetworkTests",
            dependencies: ["CSNetwork"]),
    ]
)
