**ENUM**

# `UnrestorableError`

```swift
public enum UnrestorableError: Error
```

> An error encountered during location tracking, after which the SDK can't
> restore tracking location during this app's session.

## Cases
### `invalidPublishableKey`

```swift
case invalidPublishableKey
```

> Publishable Key wan't found in HyperTrack's database.
>
> This error shouldn't happen in production, but due to its asynchronous
> nature, it can be detected only during tracking. SDK stops all functions
> until the app is recompiled with the correct Publishable Key.

### `motionActivityPermissionsDenied`

```swift
case motionActivityPermissionsDenied
```

> Motion activity permissions denied after SDK's initialization. Granting
> them will restart the app, so in effect, they are denied during this app's
> session.
