// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "HyperTrack",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "HyperTrack",
            targets: ["HyperTrack"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/groue/GRDB.swift.git", from: "4.4.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
      .binaryTarget(name: "HyperTrack",
                    url: "https://github.com/DmitryShapovalov/framework/blob/master/HyperTrack.xcframework.zip",
                    checksum: "edd0521623749f6507d965cf83c3a3f1fb1e7aea")
    ]
)
