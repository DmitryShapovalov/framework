// swift-tools-version:4.2

import PackageDescription

let package = Package(
  name: "HyperTrack",
  products: [
      .library(name: "HyperTrack", targets: ["HyperTrack"]),
  ],
  dependencies: [
    .package(name: "GRDB", url: "https://github.com/groue/GRDB.swift.git", from: "4.4.0"),
  ],
  targets: [
    .target(
      name: "HyperTrack",
      dependencies: ["GRDB"],
      path: "HyperTrack",
      exclude: [
          "objectivec",
      ])
  ]
)
