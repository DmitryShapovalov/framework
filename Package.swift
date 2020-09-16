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
      .binaryTarget(
          name: "HyperTrackTestFramework",
          url: "https://github.com/DmitryShapovalov/framework/releases/download/4.0.29/HyperTrackTestFramework.zip",
          checksum: "70c78e00e9dd1a7defc75bf2f1f7cf1617a62cfc"
      )
    ]
)

