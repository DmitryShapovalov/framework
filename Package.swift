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
          checksum: "e22654e0c996686f229c27065d553c782d507730bb57da01f271d2ac34ce20f1"
      )
    ]
  )
