// swift-tools-version:5.1

import PackageDescription

let package = Package(
  name: "HyperTrack",
  products: [
      .library(name: "HyperTrack", targets: ["HyperTrack"]),
  ],
  dependencies: [
    .package(url: "https://github.com/groue/GRDB.swift.git", ...)
  ],
  targets: [
    .target(
      name: "HyperTrack",
      dependencies: ["GRDB"]
    )
  ]
)
