// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PagingKit",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(name: "PagingKit", targets: ["PagingKit"])
    ],
    targets: [
        .target(name: "PagingKit", path: "Sources")
    ]
)

