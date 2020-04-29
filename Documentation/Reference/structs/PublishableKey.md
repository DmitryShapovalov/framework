**STRUCT**

# `PublishableKey`

```swift
public struct PublishableKey
```

> A compile-time guaranteed non-empty Publishable Key string.
>
> Copy the Publishable Key string from HyperTrack's dashboard
> [setup page](https://dashboard.hypertrack.com/setup)

## Methods
### `init(_:)`

```swift
public init?(_ publishableKey: String)
```

> Creates a Publishable Key in the same way as `URL.init(string:)` from
> Foundation.
>
>     HyperTrack(publishableKey: .init("Your_Publishable_Key")!)
>
> - Parameter publishableKey: Your Publishable Key string.

#### Parameters

| Name | Description |
| ---- | ----------- |
| publishableKey | Your Publishable Key string. |

### `init(_:_:)`

```swift
public init(_ firstCharacter: Character, _ restOfTheKey: String)
```

> Creates a Publishable Key in a type-safe way without the need for
> force-unwrap. Place the first letter of your Publishable Key in the
> `firstCharacter` argument and the rest of the key in the `restOfTheKey`
> argument.
>
>     HyperTrack(publishableKey: .init("Y", "our_Publishable_Key"))
>
> - Parameters:
>     - firstCharacter: The first character of your Publishable Key
>       string.
>     - restOfTheKey: The rest of your Publishable Key string.

#### Parameters

| Name | Description |
| ---- | ----------- |
| firstCharacter | The first character of your Publishable Key string. |
| restOfTheKey | The rest of your Publishable Key string. |