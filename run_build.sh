xcodebuild archive \
-project HyperTrackTestFramework.xcodeproj \
-scheme HyperTrackTestFramework \
-configuration Release \
-destination "generic/platform=iOS Simulator" \
-archivePath "archives/HyperTrackTestFramework-Simulator" \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild archive \
-project HyperTrackTestFramework.xcodeproj \
-scheme HyperTrackTestFramework \
-configuration Release \
-destination generic/platform=iOS \
-archivePath "archives/HyperTrackTestFramework" \
SKIP_INSTALL=NO \
BUILD_LIBRARY_FOR_DISTRIBUTION=YES

xcodebuild -create-xcframework \
           -framework archives/HyperTrackTestFramework.xcarchive/Products/Library/Frameworks/HyperTrackTestFramework.framework \
           -framework archives/HyperTrackTestFramework-Simulator.xcarchive/Products/Library/Frameworks/HyperTrackTestFramework.framework \
           -output archives/HyperTrackTestFramework.xcframework
