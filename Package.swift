// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "PagingKit",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
        .tvOS(.v11),
        .watchOS(.v4)
    ],
    products: [
        .library(name: "PagingKit", targets: ["PagingKit"])
    ],
    targets: [
        .target(name: "PagingKit", path: "Sources")
    ]
)

