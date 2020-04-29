**CLASS**

# `HyperTrack`

```swift
public final class HyperTrack
```

> An interface for HyperTrack SDK.

## Properties
### `deviceID`

```swift
public let deviceID: String
```

> A string used to identify a device uniquely.
>
> `deviceID` is stored on disk and is consistent between app runs, but every
> app reinstall will result in a new `deviceID`.

### `isRunning`

```swift
public var isRunning: Bool
```

> Reflects tracking intent.
>
> When SDK receives start command either using `start()` method, silent
> push notification, or with `syncDeviceSettings()`, it captures this
> intent. SDK tries to track until it receives a stop command through the
> means described above or if it encounters one of the following errors:
> `UnrestorableError.invalidPublishableKey`, `RestorableError.trialEnded`,
> `RestorableError.paymentDefault`.
>
> - Note: `isRunning` only reflects an intent to track, not the actual
> location tracking status. Location tracking can be blocked by a lack of
> permissions or other conditions, but if there is an intent to track, it
> will resume once those blockers are resolved. Use notifications if you
> need to react to location tracking status.

## Methods
### `init(publishableKey:)`

```swift
public init(publishableKey: PublishableKey) throws
```

> Creates an interface for the SDK.
>
> Multiple interfaces can be created without duplicating memory and
> resources.
>
> - Note: Use `makeSDK(publishableKey:)` factory method if you need an
>   explicit and type-safe error handling using `Result` type.
>
> - Parameter publishableKey: struct containing a non-empty string of
>   publishable key provided in HyperTrack's dashboard
>   [setup page](https://dashboard.hypertrack.com/setup).
>
> - Throws: An error of type `FatalError` if there is a development or
>   production blocker to SDK initialization.

#### Parameters

| Name | Description |
| ---- | ----------- |
| publishableKey | struct containing a non-empty string of publishable key provided in HyperTrack’s dashboard . |

### `makeSDK(publishableKey:)`

```swift
public static func makeSDK(publishableKey: PublishableKey) -> Result<
  HyperTrack, FatalError
>
```

> Creates and returns an SDK interface or `FatalError` if there are blockers
> to successful initialization.
>
> Multiple interfaces can be created without duplicating memory and
> resources.
>
> - Note: Use throwing initializer `init(publishableKey:) throws` if you
>   don't need to handle errors explicitly or error type-safety is not
>   critical.
>
> - Parameter publishableKey: struct containing a non-empty string of
>   publishable key provided in HyperTrack's dashboard
>   [setup page](https://dashboard.hypertrack.com/setup).
>
> - Returns: A Result with an instance for HyperTrack SDK or an error of
>   type `FatalError` if there is a development or production blocker to SDK
>   initialization.

#### Parameters

| Name | Description |
| ---- | ----------- |
| publishableKey | struct containing a non-empty string of publishable key provided in HyperTrack’s dashboard . |

### `setDeviceName(_:)`

```swift
public func setDeviceName(_ deviceName: String)
```

> Sets the device name for the current device.
>
> You can see the device name in the devices list in the Dashboard or
> through APIs.
>
> - Parameter deviceName: A human-readable string describing a device or its
>   user.

#### Parameters

| Name | Description |
| ---- | ----------- |
| deviceName | A human-readable string describing a device or its user. |

### `setDeviceMetadata(_:)`

```swift
public func setDeviceMetadata(_ metadata: Metadata)
```

> Sets the device metadata for the current device.
>
> You can see the device metadata in device view in Dashboard or through
> APIs. Metadata can help you identify devices with your internal entities
> (for example, users and their IDs).
>
> - Parameter metadata: A Metadata struct that represents a valid JSON
>   object.

#### Parameters

| Name | Description |
| ---- | ----------- |
| metadata | A Metadata struct that represents a valid JSON object. |

### `start()`

```swift
public func start()
```

> Expresses an intent to start location tracking.
>
> If something is blocking the SDK from tracking (for example, the user
> didn't grant location permissions), the appropriate notification with the
> corresponding error will be emitted. The SDK immediately starts tracking
> when blockers are resolved (when user grant the permissions), no need for
> another `start()` invocation when that happens. This intent survives app
> restarts.

### `stop()`

```swift
public func stop()
```

> Stops location tracking immediately.

### `syncDeviceSettings()`

```swift
public func syncDeviceSettings()
```

> Synchronizes device settings with HyperTrack's platform.
>
> If you are using silent push notifications to start and end trips, this
> method can be used as a backup when push notification delivery fails.
> Place it in AppDelegate and additionally on screens where you expect
> tracking to start (screens that trigger subsequent tracking, screens after
> user login, etc.).

### `addTripMarker(_:)`

```swift
public func addTripMarker(_ marker: Metadata)
```

> Adds a new trip marker.
>
> Use trip markers to mark a location at the current timestamp with
> metadata. This marker can represent any custom event in your system that
> you want to attach to location data (a moment when the delivery completed,
> a worker checking in, etc.).
>
> - Note: Actual data is sent to servers when conditions are optimal. Calls
>   made to this API during an internet outage will be recorded and sent
>   when the connection is available.
>
> - Parameter marker: A Metadata struct that represents a valid JSON
>   object.

#### Parameters

| Name | Description |
| ---- | ----------- |
| marker | A Metadata struct that represents a valid JSON object. |

### `registerForRemoteNotifications()`

```swift
public static func registerForRemoteNotifications()
```

> Registers for silent push notifications.
>
> Call this method in
> `application(_:didFinishLaunchingWithOptions:launchOptions:)`

### `didRegisterForRemoteNotificationsWithDeviceToken(_:)`

```swift
public static func didRegisterForRemoteNotificationsWithDeviceToken(
  _ deviceToken: Data
)
```

> Updates device token for the current device.
>
> Call this method to handle successful remote notification registration
> in `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`
>
> - Parameter deviceToken: The device token passed to
> `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)`

#### Parameters

| Name | Description |
| ---- | ----------- |
| deviceToken | The device token passed to `application(_:didRegisterForRemoteNotificationsWithDeviceToken:)` |

### `didFailToRegisterForRemoteNotificationsWithError(_:)`

```swift
public static func didFailToRegisterForRemoteNotificationsWithError(
  _ error: Error
)
```

> Tranfers the registration error to HyperTrack SDK.
>
> Call this method to handle unsuccessful remote notification registration
> in `application(_:didFailToRegisterForRemoteNotificationsWithError:)`
>
> - Parameter error: The error object passed to
>   `application(_:didFailToRegisterForRemoteNotificationsWithError:)`

#### Parameters

| Name | Description |
| ---- | ----------- |
| error | The error object passed to `application(_:didFailToRegisterForRemoteNotificationsWithError:)` |

### `didReceiveRemoteNotification(_:fetchCompletionHandler:)`

```swift
public static func didReceiveRemoteNotification(
  _ userInfo: [AnyHashable: Any],
  fetchCompletionHandler completionHandler: @escaping (
    UIBackgroundFetchResult
  ) -> Void
)
```

> Tranfers the silent push notification to HyperTrack SDK.
>
> Call this method to handle a silent push notification in
> `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`
>
> - Note: SDK ignores push notifications meant for your app, but if you want
>   to make sure it doesn't receive them use "hypertrack" key inside the
>   `userInfo` object:
>
>       if userInfo["hypertrack"] != nil {
>           // This is HyperTrack's notification
>           HyperTrack.didReceiveRemoteNotification(
>               userInfo,
>               fetchCompletionHandler: completionHandler)
>       } else {
>           // Handle your server's notification here
>       }
>
> - Parameters:
>     - userInfo: The `userInfo` dictionary passed to
>       `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`
>     - completionHandler: The handler function passed to
>       `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)`

#### Parameters

| Name | Description |
| ---- | ----------- |
| userInfo | The `userInfo` dictionary passed to `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` |
| completionHandler | The handler function passed to `application(_:didReceiveRemoteNotification:fetchCompletionHandler:)` |