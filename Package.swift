// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "HyperTrack"
let version = "4.0.50-rc.2"

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
        url: "https://github.com/DmitryShapovalov/framework/releases/download/4.0.51-rc.2/HyperTrack.xcframework.zip",
        checksum: "9dda618e9825afe77b1aff1167b8b26e2a0694ae1635b13ac984b789a9844fe1"
    )
    ],
  swiftLanguageVersions: [
    .v5
  ]
)
