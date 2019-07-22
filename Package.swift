// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "FlowLayout",
    platforms: [
        .macOS(.v11_0),
    ],
    products: [
        .library(name: "FlowLayout", targets: ["FlowLayout"]),
    ],
    targets: [
        .target(name: "FlowLayout", dependencies: []),
    ]
)
