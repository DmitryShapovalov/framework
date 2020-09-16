// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HyperTrackTestFramework",
    platforms: [
        .iOS(.v11)
    ],
    products: [
        .library(
            name: "HyperTrackTestFramework",
            targets: ["HyperTrackTestFramework"]),
    ],
    dependencies: [
    ],
    targets: [
      .binaryTarget(name: "HyperTrackTestFramework", path: "HyperTrackTestFramework.xcframework")
    ]
)
