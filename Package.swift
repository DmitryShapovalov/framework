// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "HyperTrack"
let version = "999.0.0"

let package = Package(
    name: name,
    platforms: [
      .iOS(.v11)
    ],
    products: [
      .library(
          name: name,
          targets: [name]),
    ],
    targets: [
    .binaryTarget(
        name: name,
        url: "https://github.com/DmitryShapovalov/framework/releases/download/4.0.37/HyperTrack.xcframework.zip",
        checksum: "8e91fa14fbd6c60a0558e3802b0266bad12ae6f1530226958db1048a35940a40"
    )
    ],
  swiftLanguageVersions: [
    .v5
  ]
)
