**ENUM**

# `FatalError`

```swift
public enum FatalError: Error
```

> A grouping of errors that can be emitted during initialization.

## Cases
### `developmentError(_:)`

```swift
case developmentError(DevelopmentError)
```

### `productionError(_:)`

```swift
case productionError(ProductionError)
```

## Properties
### `developmentError`

```swift
public var developmentError: DevelopmentError?
```

> A convenience property to retrieve `DevelopmentError` associated enum.

### `productionError`

```swift
public var productionError: ProductionError?
```

> A convenience property to retrieve `ProductionError` associated enum.
