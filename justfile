alias a := analyze
alias d := docs
alias f := format
alias i := install
alias l := lint
alias o := open
alias r := release

analyze:
    rm -rf ~/Library/Developer/Xcode/DerivedData
    xcodebuild -workspace 'HyperTrack.xcworkspace' -scheme 'HyperTrack' -destination generic/platform=iOS build CODE_SIGN_IDENTITY="" CODE_SIGNING_REQUIRED=NO > xcodebuild.log
    swiftlint analyze --path HyperTrack --config ../.swiftlint.yml --compiler-log-path xcodebuild.log || (rm xcodebuild.log && exit 1)
    rm xcodebuild.log

docs:
    sourcedocs generate --clean -- -scheme HyperTrack
    rm Documentation/Reference/enums/Result.md

format:
    swiftformat . --swiftversion 4.2

install:
    rm -rf Pods HyperTrack.xcodeproj HyperTrack.xcworkspace
    xcodegen generate
    pod install

lint:
    swiftlint lint --path HyperTrack --config ../.swiftlint.yml
    swiftlint lint --path SDKTest --config ../.swiftlint.yml
    swiftlint lint --path Trips --config ../.swiftlint.yml

open:
    open HyperTrack.xcworkspace

release:
    rm -f HyperTrack.zip
    find ./HyperTrack -type f \( -name \*.swift -o -iname \*.h -o -name \*.m \) -print | zip HyperTrack -@ -j
