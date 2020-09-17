// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let name = "HyperTrack"
let version = "5.0.0"

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
      .binaryTarget(name: "HyperTrack.xcframework",
                    path: "/HyperTrack.xcframework")
    ],
  swiftLanguageVersions: [
    .v5
  ]
)
