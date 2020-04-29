# HyperTrack iOS SDK Development

This repo contains the code for iOS SDK.

## Documentation

[Public docs](http://hypertrack.com/docs/references/#references-sdks-ios)

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

You'll need:
* [Xcode 10.3 or higher](https://developer.apple.com/xcode/)
* [Xcodegen](https://github.com/yonaskolb/XcodeGen)
* [CocoaPods](https://guides.cocoapods.org/using/getting-started.html#installation)
* [just](https://github.com/casey/just)

### Installing

1. Clone this repo
2. Run `just install`
3. Open `just open`

## Deploying

1. Bump the version for [Constants.version](https://github.com/hypertrack/sdk-ios-hidden/blob/bc19cf7e78275ff14f5dca5f77ac3535fb79f527/HyperTrack/Utility/Constants.swift#L6) following [Semantic Versioning](https://semver.org).
2. Make a commit to `master` with this bump.
3. Tag the above commit with the version number.
4. Run `just release` to generate the zip archive.
5. Bump the version in [HyperTrack.podspec](https://github.com/hypertrack/sdk-ios/blob/dc4c901ae67498b00fd4c36fe4b0b84876b30c99/HyperTrack.podspec#L5)
6. Make a commit to `master` with this bump.
7. [Create a new release](https://github.com/hypertrack/sdk-ios/releases/new). Make sure that "Target" is `master`. Set "Tag version" to the new version. If this release is a public release, fill out the "Release title" and "Description" following the [guidelines](https://github.com/hypertrack/wiki/wiki/git-Guidelines#types-of-changes). Look at other releases for inspiration. If this is a pre-release, leave those fields blank and check the "This is a pre-release" checkmark. Attach the zip file generated in step 4 and publish the release.
8. CD into the `sdk-ios` repo's folder in terminal (make sure that you pulled `master`) and push the release to CocoaPods using `pod trunk push HyperTrack.podspec --allow-warnings`
