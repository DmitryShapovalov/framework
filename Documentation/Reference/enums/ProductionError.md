**ENUM**

# `ProductionError`

```swift
public enum ProductionError: Error
```

> Runtime errors that block the SDK initialization until the app is restarted
> or forever for the current device.

## Cases
### `locationServicesUnavalible`

```swift
case locationServicesUnavalible
```

> The device doesn't have GPS capabilities, or it is malfunctioning.

### `motionActivityServicesUnavalible`

```swift
case motionActivityServicesUnavalible
```

> The device doesn't have Motion capabilities, or it is malfunctioning.

### `motionActivityPermissionsDenied`

```swift
case motionActivityPermissionsDenied
```

> Motion activity permissions denied before SDK initialization. Granting
> them will restart the app, so in effect, they are denied during this app's
> session.
