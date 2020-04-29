**ENUM**

# `RestorableError`

```swift
public enum RestorableError: Error
```

> An error encountered during location tracking, after which the SDK can
> restore tracking location during this app's session.

## Cases
### `locationPermissionsDenied`

```swift
case locationPermissionsDenied
```

> The user denied location permissions.

### `locationServicesDisabled`

```swift
case locationServicesDisabled
```

> The user disabled location services systemwide.

### `motionActivityServicesDisabled`

```swift
case motionActivityServicesDisabled
```

> The user disabled motion services systemwide.

### `networkConnectionUnavailable`

```swift
case networkConnectionUnavailable
```

> There was no network connection for 12 hours.
>
> SDK stops collecting location data after 12 hours without a network
> connection. It automatically resumes tracking after the connection is
> restored.

### `trialEnded`

```swift
case trialEnded
```

> HyperTrack's trial period has ended.

### `paymentDefault`

```swift
case paymentDefault
```

> There was an error processing your payment.
