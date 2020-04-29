import CoreLocation
import Foundation

protocol AbstractLocationService: AbstractService {
  func requestPermissions(
    _ completionHandler: @escaping LocationCompletionHandler
  )
}

final class LocationService: AbstractLocationService {
  fileprivate var locationManager: AbstractLocationManager
  fileprivate var locationTrackingMode: AbstractLocationTrackingMode
  fileprivate weak var config: AbstractLocationConfig?
  fileprivate weak var appState: AbstractAppState?
  weak var collectionProtocol: AbstractCollectionPipeline?
  weak var eventBus: AbstractEventBus?

  init(
    config: AbstractLocationConfig?,
    locationManager: AbstractLocationManager,
    collection: AbstractCollectionPipeline?,
    eventBus: AbstractEventBus?,
    appState: AbstractAppState?
  ) {
    self.config = config
    self.appState = appState
    self.locationManager = locationManager
    collectionProtocol = collection
    self.eventBus = eventBus
    locationTrackingMode = LocationTrackingMode()
    self.locationManager.updatesDelegate = self
    locationTrackingMode.delegate = self
    self.eventBus?.addObserver(
      self,
      selector: #selector(updateConfig(_:)),
      name: Constant.Notification.Config.ConfigChangedEvent.name
    )
    self.eventBus?.addObserver(
      self,
      selector: #selector(handleActivityChange(_:)),
      name: Constant.Notification.Activity.ActivityChangedEvent.name
    )
  }

  @objc private func updateConfig(_: Notification) {
    locationManager.updateConfig(config)
  }

  @objc private func handleActivityChange(_ notification: Notification) {
    guard
      let type =
      notification.userInfo?[
        Constant.Notification.Activity.ActivityChangedEvent.key
      ]
      as? ActivityServiceData
      else { return }
    locationTrackingMode.updateActivity(type)
  }
}

extension LocationService {
  func requestPermissions(
    _ completionHandler: @escaping LocationCompletionHandler
  ) { locationManager.requestPermissions(completionHandler) }

  func isAuthorized() -> Bool { return locationManager.isAuthorized }

  func checkPermissionStatus() { locationManager.checkPermission() }

  func startService() throws -> ServiceError? {
    guard !isServiceRunning() else { return nil }
    locationTrackingMode.setInitialState { [weak self] in
      guard let self = self else { return }
      try? self.locationManager.startService()
    }
    return nil
  }

  func stopService() {
    do {
      locationTrackingMode.setFinalState()
      try locationManager.stopService()
    } catch {}
  }

  func isServiceRunning() -> Bool { return locationManager.isServiceRunning }
}

extension LocationService: LocationUpdateDelegate {
  func locationUpdates(_ locations: [CLLocation]) {
    locationTrackingMode.locationUpdateHandler(locations)
  }
}

extension LocationService: LocationTrackingModeDelegate {
  func updateLocationManagerSettings(
    _ accuracy: CLLocationAccuracy,
    _ distanceFilter: CLLocationDistance
  ) {
    locationManager.updateSettings(accuracy, distanceFilter)
  }

  func availableLocation(_ locations: [LocationServiceData]) {
    collectionProtocol?.sendEvents(
      events: locations
    )
  }
}
