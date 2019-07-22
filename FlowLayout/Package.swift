// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "FlowLayout",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "FlowLayout",
            targets: ["FlowLayout"]),
    ],
    targets: [
        .target(
            name: "FlowLayout",
            dependencies: [],
            path: ""),
    ]
)
