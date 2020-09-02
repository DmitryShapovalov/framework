// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HyperTrackSPM",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HyperTrackSPM",
            targets: ["HyperTrackSPM"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
//        .package(url: "https://github.com/groue/GRDB.swift.git", from: "4.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
      .target(
          name: "HyperTrackSPM",
          dependencies: ["HyperTrack"]
      ),
      .binaryTarget(name: "HyperTrack",
                    url: "https://s3-us-west-2.amazonaws.com/sdk-config.hypertrack.com/HyperTrack.xcframework.zip",
                    checksum: "60a5118aed4da1d95972dfccf26b5c052ba0ef5cdcd7975b8b4eab8154a696ca")
    ]
)
