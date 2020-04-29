**ENUM**

# `TrackingError`

```swift
public enum TrackingError
```

> A grouping of errors that can be emitted during tracking.
>
> Use this type with a `hyperTrackTrackingError()` function if you are
> subscribed to both restorable and unrestorable error notifications for the
> same selector.

## Cases
### `restorableError(_:)`

```swift
case restorableError(RestorableError)
```

### `unrestorableError(_:)`

```swift
case unrestorableError(UnrestorableError)
```

## Properties
### `restorableError`

```swift
public var restorableError: RestorableError?
```

> A convenience property to retrieve `RestorableError` associated enum.

### `unrestorableError`

```swift
public var unrestorableError: UnrestorableError?
```

> A convenience property to retrieve `UnrestorableError` associated enum.
