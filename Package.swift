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
          url: "https://github.com/DmitryShapovalov/framework/releases/download/4.0.26/HyperTrackTestFramework.xcframework.zip",
          checksum: "cf83e1357eefb8bdf1542850d66d8007d620e4050b5715dc83f4a921d36ce9ce47d0d13c5d85f2b0ff8318d2877eec2f63b931bd47417a81a538327af927da3e"
      )
    ]
)

