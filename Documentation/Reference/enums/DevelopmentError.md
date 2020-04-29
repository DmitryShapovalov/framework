**ENUM**

# `DevelopmentError`

```swift
public enum DevelopmentError: Error
```

> Errors that can be emitted during the development and integration of the
> SDK.
>
> Those errors should be resolved before going to production.

## Cases
### `missingLocationUpdatesBackgroundModeCapability`

```swift
case missingLocationUpdatesBackgroundModeCapability
```

> "Location updates" mode is not set in your target's "Signing &
> Capabilities".

### `runningOnSimulatorUnsupported`

```swift
case runningOnSimulatorUnsupported
```

> You are running the SDK on the iOS simulator, which currently does not
> support CoreMotion services. You can test the SDK on real iOS devices
> only.
