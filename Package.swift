// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "HyperTrack",
  platforms: [
    .iOS(.v12),
  ],
  products: [
      .library(name: "HyperTrack", targets: ["HyperTrack"]),
  ],
  dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift.git", from: "4.4.0"),
  ],
  targets: [
    .target(
      name: "HyperTrack",
      dependencies: ["GRDB"],
      path: "HyperTrack")
  ],
  swiftLanguageVersions: [.v4_2, .version("5")]
)
