**STRUCT**

# `Metadata`

```swift
public struct Metadata: RawRepresentable
```

> A structure  that represents a valid metadata.
>
> Currently being a valid JSON is the only requirement for Metadata, but
> new requirements can be added in the future.

## Properties
### `rawValue`

```swift
public let rawValue: RawValue
```

## Methods
### `init()`

```swift
public init()
```

> Creates an empty metadata.

### `init(rawValue:)`

```swift
public init?(rawValue: RawValue)
```

#### Parameters

| Name | Description |
| ---- | ----------- |
| rawValue | The raw value to use for the new instance. |

### `init(dictionary:)`

```swift
public init(dictionary: [String: Any]) throws
```

> Creates metadata from a Dictonary type.
>
> - Parameter dictionary: A key-value dictionary containing types
>   representable in JSON.
>
> - Throws: An error of type `MetadataError`.

#### Parameters

| Name | Description |
| ---- | ----------- |
| dictionary | A key-value dictionary containing types representable in JSON. |

### `makeMetadata(dictionary:)`

```swift
public static func makeMetadata(dictionary: [String: Any]) -> Result<
  Metadata, MetadataError
>
```

> Creates and returns a Metadata value or MetadataError.
>
> - Parameter dictionary: A key-value dictionary containing types
>   representable in JSON.
>
> - Returns: A Result with a Metadata value or an error of type
>   `MetadataError` if the dictionary contains types that cannot serialize
>   to JSON.

#### Parameters

| Name | Description |
| ---- | ----------- |
| dictionary | A key-value dictionary containing types representable in JSON. |

### `init(jsonString:)`

```swift
public init(jsonString: String) throws
```

> Creates a Metadata value from a JSON string.
>
> - Parameter jsonString: A string that can be serialized to JSON.
>
> - Throws: An error of type `MetadataError` if the string cannot be
>   serialized.

#### Parameters

| Name | Description |
| ---- | ----------- |
| jsonString | A string that can be serialized to JSON. |

### `makeMetadata(jsonString:)`

```swift
public static func makeMetadata(jsonString: String) -> Result<
  Metadata, MetadataError
>
```

> Creates and returns a Metadata value or MetadataError.
>
> - Parameter jsonString: A string that can be serialized to JSON.
>
> - Returns: A Result with a Metadata value or an error of type
>   `MetadataError` if the string cannot be serialized.

#### Parameters

| Name | Description |
| ---- | ----------- |
| jsonString | A string that can be serialized to JSON. |