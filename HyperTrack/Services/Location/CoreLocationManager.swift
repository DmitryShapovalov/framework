import CoreLocation

typealias LocationCompletionHandler = (PrivateDataAccessLevel) -> Void

protocol LocationUpdateDelegate: AnyObject {
  func locationUpdates(_ locations: [CLLocation])
}

protocol AbstractLocationManager {
  var isServiceRunning: Bool { get }
  var isAuthorized: Bool { get }
  var updatesDelegate: LocationUpdateDelegate? { get set }
  func startService() throws
  func stopService() throws
  func updateConfig(_ config: AbstractLocationConfig?)
  func requestPermissions(
    _ completionHandler: @escaping LocationCompletionHandler
  )
  func updateSettings(
    _ accuracy: CLLocationAccuracy,
    _ distanceFilter: CLLocationDistance
  )
  func checkPermission()
}

final class CoreLocationManager: NSObject, AbstractLocationManager {
  fileprivate let lastCurrentLocationPermissionKey =
    "HTSDKlastCurrentLocationPermissionKey"
  fileprivate var currentPermissionState: PrivateDataAccessLevel?
  fileprivate weak var dataStore: AbstractReadWriteDataStore?
  fileprivate weak var config: AbstractLocationConfig?
  fileprivate let locationManager: CLLocationManager
  weak var updatesDelegate: LocationUpdateDelegate?
  var permissionCallback: LocationCompletionHandler?
  fileprivate weak var eventBus: AbstractEventBus?
  var isServiceRunning: Bool = false
  var lastCoordinate: CLLocationCoordinate2D?

  var isAuthorized: Bool {
    let authorizationStatus = CLLocationManager.authorizationStatus()
    switch authorizationStatus {
      case .authorizedAlways, .authorizedWhenInUse: return true
      case .denied, .restricted, .notDetermined: return false
      @unknown default:
        logLocation.fault(
          "Failed to handle CLLocationManager.authorizationStatus: \(authorizationStatus.rawValue), status is unknown"
        )
        fatalError()
    }
  }

  init(
    config: AbstractLocationConfig?,
    eventBus: AbstractEventBus?,
    dataStore: AbstractReadWriteDataStore?
  ) {
    locationManager = CLLocationManager()
    self.config = config
    self.eventBus = eventBus
    self.dataStore = dataStore
    super.init()

    if let savedLocationPermissionState = dataStore?.string(
      forKey: lastCurrentLocationPermissionKey
    ) {
      currentPermissionState = PrivateDataAccessLevel(
        rawValue: savedLocationPermissionState
      )
    }

    updateConfig(config)
  }

  func updateConfig(_ config: AbstractLocationConfig?) {
    guard let config = config else { return }
    locationManager.allowsBackgroundLocationUpdates =
      config.location.backgroundLocationUpdates
    locationManager.desiredAccuracy = kCLLocationAccuracyBest
    locationManager.pausesLocationUpdatesAutomatically =
      config.location.pausesLocationUpdatesAutomatically
    locationManager.activityType = CLActivityType.automotiveNavigation
    locationManager.distanceFilter = config.location.distanceFilter
    locationManager.delegate = self
    if #available(iOS 11.0, *) {
      self.locationManager.showsBackgroundLocationIndicator =
        config.location.showsBackgroundLocationIndicator
    }
  }

  func startService() throws {
    logLocation.log("Starting service")
    guard let config = config else {
      logLocation.error(
        "Failed to start LocationService with error config: nil"
      )
      return
    }
    if isAuthorized {
      isServiceRunning = true
      if config.location.onlySignificantLocationUpdates {
        locationManager.startMonitoringSignificantLocationChanges()
      } else {
        locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
      }
    } else {
      try? stopService()
      isServiceRunning = false
      throw SDKError(.locationPermissionsDenied)
    }
  }

  func stopService() throws {
    logLocation.log("Stopping service")
    guard let config = config else {
      logLocation.error("Failed to stop LocationService with error config: nil")
      return
    }
    if config.location.onlySignificantLocationUpdates {
      locationManager.stopMonitoringSignificantLocationChanges()
    } else {
      locationManager.stopMonitoringSignificantLocationChanges()
      locationManager.stopUpdatingLocation()
    }
    isServiceRunning = false
    lastCoordinate = nil
  }

  func requestPermissions(
    _ completionHandler: @escaping LocationCompletionHandler
  ) {
    permissionCallback = completionHandler
    let status = CLLocationManager.authorizationStatus()
    if locationServicesAlreadyRequested(status: status) {
      locationManager(locationManager, didChangeAuthorization: status)
    } else {
      guard let type = config?.location.permissionType else { return }
      switch type {
        case .always: locationManager.requestAlwaysAuthorization()
        default: locationManager.requestWhenInUseAuthorization()
      }
    }
  }

  func updateSettings(
    _ accuracy: CLLocationAccuracy,
    _ distanceFilter: CLLocationDistance
  ) {
    locationManager.desiredAccuracy = accuracy
    locationManager.distanceFilter = distanceFilter
    logLocation.log(
      "Location Manager did change desiredAccuracy on: \(accuracy) and distanceFilter: \(distanceFilter)"
    )
  }

  fileprivate func locationServicesAlreadyRequested(
    status: CLAuthorizationStatus
  ) -> Bool {
    switch status {
      case .authorizedAlways, .authorizedWhenInUse, .denied, .restricted:
        return true
      case .notDetermined: return false
      @unknown default:
        logLocation.fault(
          "Failed to check if loacation services was already requested with CLAuthorizationStatus: \(status.rawValue), with status unknown"
        )
        fatalError()
    }
  }

  fileprivate func authStatusToAccessLevel(_ status: CLAuthorizationStatus)
    -> PrivateDataAccessLevel {
      switch status {
        case .authorizedAlways: return .grantedAlways
        case .authorizedWhenInUse: return .grantedWhenInUse
        case .denied: return .denied
        case .restricted: return .restricted
        case .notDetermined: return .undetermined
      @unknown default:
          logLocation.fault(
            "Failed transform CLAuthorizationStatus: \(status.rawValue) to PrivateDataAccessLevel with status unknown"
          )
          fatalError()
      }
  }

  func checkPermission() {
    let status = CLLocationManager.authorizationStatus()
    sendAuthorizationStatus(status: status)
  }

  fileprivate func sendAuthorizationStatus(status: CLAuthorizationStatus) {
    var updatedStatus: CLAuthorizationStatus = status
    if CLLocationManager.locationServicesEnabled() == false {
      updatedStatus = .restricted
    }
    if currentPermissionState != authStatusToAccessLevel(updatedStatus) {
      self.currentPermissionState = authStatusToAccessLevel(updatedStatus)
      eventBus?.post(
        name: Constant.Notification.Location.PermissionChangedEvent.name,
        userInfo: [
          Constant.Notification.Location.PermissionChangedEvent.key:
            authStatusToAccessLevel(updatedStatus)
        ]
      )
      guard let currentPermissionState = self.currentPermissionState else {
        return
      }
      dataStore?.set(
        currentPermissionState.rawValue,
        forKey: lastCurrentLocationPermissionKey
      )
    }
  }
}

extension CoreLocationManager: CLLocationManagerDelegate {
  func locationManager(
    _: CLLocationManager,
    didChangeAuthorization status: CLAuthorizationStatus
  ) {
    logLocation.log(
      "Location Manager did change authorization status:\(status.rawValue)"
    )
    permissionCallback?(authStatusToAccessLevel(status))
    permissionCallback = nil
    sendAuthorizationStatus(status: status)
  }

  func locationManager(
    _: CLLocationManager,
    didUpdateLocations locations: [CLLocation]
  ) {
    logLocation.log("Received locations: \(locations)")
    let filteredLocations: [CLLocation]
    if !locations.isEmpty, let lastCoordinate = lastCoordinate {
      filteredLocations = locations.filter { location in
        if coordinate(location.coordinate, isAlmostEqualTo: lastCoordinate) {
          logLocation
            .log("Discarding location: \(location) because it's almost equal to lastCoordinate: \(lastCoordinate)")
          return false
        } else {
          return true
        }
      }
    } else {
      filteredLocations = locations
    }
    if let lastLocation = filteredLocations.last {
      lastCoordinate = lastLocation.coordinate
    }

    if !filteredLocations.isEmpty {
      logLocation.log(
        "Received location update with locations:\(filteredLocations)"
      )
      updatesDelegate?.locationUpdates(filteredLocations)
    }
  }

  func locationManager(
    _: CLLocationManager,
    didFailWithError error: Error
  ) {
    logLocation.error(
      "Failed to update locations with CLLocationManager error: \(error)"
    )
  }
}

func coordinate(
  _ coordinate1: CLLocationCoordinate2D,
  isAlmostEqualTo coordinate2: CLLocationCoordinate2D
) -> Bool {
  let precision = Constant.Config.Location.coordinatePrecisionPlaces
  let tolerance = 1.0 / Double(pow(10.0, Double(precision)))
  if Double(coordinate1.latitude.rounded(precision)).isAlmostEqual(
    to: Double(coordinate2.latitude.rounded(precision)),
    tolerance: tolerance
  ),
    Double(coordinate1.longitude.rounded(precision)).isAlmostEqual(
      to: Double(coordinate2.longitude.rounded(precision)),
      tolerance: tolerance
    ) {
    return true
  } else {
    return false
  }
}

/// From https://github.com/apple/swift-evolution/blob/master/proposals/0259-approximately-equal.md
extension FloatingPoint {
  /// Test approximate equality with relative tolerance.
  ///
  /// Do not use this function to check if a number is approximately
  /// zero; no reasoned relative tolerance can do what you want for
  /// that case. Use `isAlmostZero` instead for that case.
  ///
  /// The relation defined by this predicate is symmetric and reflexive
  /// (except for NaN), but *is not* transitive. Because of this, it is
  /// often unsuitable for use for key comparisons, but it can be used
  /// successfully in many other contexts.
  ///
  /// The internet is full advice about what not to do when comparing
  /// floating-point values:
  ///
  /// - "Never compare floats for equality."
  /// - "Always use an epsilon."
  /// - "Floating-point values are always inexact."
  ///
  /// Much of this advice is false, and most of the rest is technically
  /// correct but misleading. Almost none of it provides specific and
  /// correct recommendations for what you *should* do if you need to
  /// compare floating-point numbers.
  ///
  /// There is no uniformly correct notion of "approximate equality", and
  /// there is no uniformly correct tolerance that can be applied without
  /// careful analysis. This function considers two values to be almost
  /// equal if the relative difference between them is smaller than the
  /// specified `tolerance`.
  ///
  /// The default value of `tolerance` is `sqrt(.ulpOfOne)`; this value
  /// comes from the common numerical analysis wisdom that if you don't
  /// know anything about a computation, you should assume that roughly
  /// half the bits may have been lost to rounding. This is generally a
  /// pretty safe choice of tolerance--if two values that agree to half
  /// their bits but are not meaningfully almost equal, the computation
  /// is likely ill-conditioned and should be reformulated.
  ///
  /// For more complete guidance on an appropriate choice of tolerance,
  /// consult with a friendly numerical analyst.
  ///
  /// - Parameters:
  ///   - other: the value to compare with `self`
  ///   - tolerance: the relative tolerance to use for the comparison.
  ///     Should be in the range (.ulpOfOne, 1).
  ///
  /// - Returns: `true` if `self` is almost equal to `other`; otherwise
  ///   `false`.
  @inlinable
  public func isAlmostEqual(
    to other: Self,
    tolerance: Self = Self.ulpOfOne.squareRoot()
  ) -> Bool {
    // tolerances outside of [.ulpOfOne,1) yield well-defined but useless results,
    // so this is enforced by an assert rathern than a precondition.
    assert(
      tolerance >= .ulpOfOne && tolerance < 1,
      "tolerance should be in [.ulpOfOne, 1)."
    )
    // The simple computation below does not necessarily give sensible
    // results if one of self or other is infinite; we need to rescale
    // the computation in that case.
    guard isFinite, other.isFinite else {
      return rescaledAlmostEqual(to: other, tolerance: tolerance)
    }
    // This should eventually be rewritten to use a scaling facility to be
    // defined on FloatingPoint suitable for hypot and scaled sums, but the
    // following is good enough to be useful for now.
    let scale = max(abs(self), abs(other), .leastNormalMagnitude)
    return abs(self - other) < scale * tolerance
  }

  /// Test if this value is nearly zero with a specified `absoluteTolerance`.
  ///
  /// This test uses an *absolute*, rather than *relative*, tolerance,
  /// because no number should be equal to zero when a relative tolerance
  /// is used.
  ///
  /// Some very rough guidelines for selecting a non-default tolerance for
  /// your computation can be provided:
  ///
  /// - If this value is the result of floating-point additions or
  ///   subtractions, use a tolerance of `.ulpOfOne * n * scale`, where
  ///   `n` is the number of terms that were summed and `scale` is the
  ///   magnitude of the largest term in the sum.
  ///
  /// - If this value is the result of floating-point multiplications,
  ///   consider each term of the product: what is the smallest value that
  ///   should be meaningfully distinguished from zero? Multiply those terms
  ///   together to get a tolerance.
  ///
  /// - More generally, use half of the smallest value that should be
  ///   meaningfully distinct from zero for the purposes of your computation.
  ///
  /// For more complete guidance on an appropriate choice of tolerance,
  /// consult with a friendly numerical analyst.
  ///
  /// - Parameter absoluteTolerance: values with magnitude smaller than
  ///   this value will be considered to be zero. Must be greater than
  ///   zero.
  ///
  /// - Returns: `true` if `abs(self)` is less than `absoluteTolerance`.
  ///            `false` otherwise.
  @inlinable
  public func isAlmostZero(
    absoluteTolerance tolerance: Self = Self.ulpOfOne.squareRoot()
  ) -> Bool {
    assert(tolerance > 0)
    return abs(self) < tolerance
  }

  /// Rescales self and other to give meaningful results when one of them
  /// is infinite. We also handle NaN here so that the fast path doesn't
  /// need to worry about it.
  @usableFromInline
  internal func rescaledAlmostEqual(to other: Self, tolerance: Self) -> Bool {
    // NaN is considered to be not approximately equal to anything, not even
    // itself.
    if isNaN || other.isNaN { return false }
    if isInfinite {
      if other.isInfinite { return self == other }
      // Self is infinite and other is finite. Replace self with the binade
      // of the greatestFiniteMagnitude, and reduce the exponent of other by
      // one to compensate.
      let scaledSelf = Self(
        sign: sign,
        exponent: Self.greatestFiniteMagnitude.exponent,
        significand: 1
      )
      let scaledOther = Self(
        sign: .plus,
        exponent: -1,
        significand: other
      )
      // Now both values are finite, so re-run the naive comparison.
      return scaledSelf.isAlmostEqual(to: scaledOther, tolerance: tolerance)
    }
    // If self is finite and other is infinite, flip order and use scaling
    // defined above, since this relation is symmetric.
    return other.rescaledAlmostEqual(to: self, tolerance: tolerance)
  }
}
