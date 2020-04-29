import CoreLocation
import Foundation

protocol LocationTrackingModeDelegate: AnyObject {
  func availableLocation(_ locations: [LocationServiceData])
  func updateLocationManagerSettings(
    _ accuracy: CLLocationAccuracy,
    _ distanceFilter: CLLocationDistance
  )
}

protocol AbstractLocationTrackingMode {
  var delegate: LocationTrackingModeDelegate? { get set }
  func updateActivity(_ activity: ActivityServiceData)
  func locationUpdateHandler(_ locations: [CLLocation])
  func setInitialState(_ completionHandler: @escaping () -> Void)
  func setFinalState()
}

final class LocationTrackingMode {
  private let activityTimer: GCDRepeatingTimer = GCDRepeatingTimer(
    timeInterval: 0,
    repeating: false
  )
  private let criticalTimer: GCDRepeatingTimer = GCDRepeatingTimer(
    timeInterval: Constant.Config.LocationTrackingMode.CriticalMode
      .checkInterval, repeating: false
  )
  private let heartbeatTimer: GCDRepeatingTimer = GCDRepeatingTimer(
    timeInterval: Constant.Config.LocationTrackingMode.Heartbeat.checkInterval,
    repeating: false
  )
  private var locationsBuffer: [LocationServiceData] = []
  private var state: TrackingStateMachine = TrackingStateMachine.initialState
    .state
  private var currentActivity: ActivityServiceData?
  private var lastCoordinate: LocationServiceData?
  private var lastAccurateStopCoordinate: LocationServiceData?
  private let serialQueue = DispatchQueue(label: "com.hypertrack.ltm.serial")
  private var startTrackingDate: Date?

  weak var delegate: LocationTrackingModeDelegate?

  init() {
    criticalTimer.eventHandler = { [weak self] in
      guard let self = self else { return }
      self.serialQueue.async {
        _ = self.state.handleEvent(.criticalTimerFired).map(self.handleAction(
          _:
        ))
      }
    }
    heartbeatTimer.eventHandler = { [weak self] in
      guard let self = self else { return }
      self.serialQueue.async {
        _ = self.state.handleEvent(.heartbeatTimerFired).map(self.handleAction(
          _:
        ))
      }
    }
    activityTimer.eventHandler = { [weak self] in
      guard let self = self else { return }
      self.serialQueue.async {
        _ = self.state.handleEvent(.activityTimerFired).map(self.handleAction(
          _:
        ))
      }
    }
  }

  func handleAction(_ action: TrackingStateMachine.Action) {
    switch action {
      case .setStartSettings:
        DispatchQueue.main.sync {
          self.delegate?.updateLocationManagerSettings(
            kCLLocationAccuracyHundredMeters,
            kCLDistanceFilterNone
          )
        }

      case .setCriticalSettings:
        DispatchQueue.main.sync {
          self.delegate?.updateLocationManagerSettings(
            kCLLocationAccuracyBest,
            kCLDistanceFilterNone
          )
        }

      case .setActivitySettings:
        guard let activity = currentActivity?.data.type else {
          locationTrackingMode.error("No activity object found")
          return
        }
        DispatchQueue.main.sync {
          self.delegate?.updateLocationManagerSettings(
            kCLLocationAccuracyBest,
            activity.getActivityValue().distance
          )
        }

      case .sendLocations:
        DispatchQueue.main.sync {
          if let activity = currentActivity,
            let type = activity.data.type {
            if type == .stop {
              if self.locationsBuffer.count > 1 {
                let sorted = self.locationsBuffer.sorted {
                  $0.data.location_accuracy < $1.data.location_accuracy
                }
                if let lastAccurate = self.lastAccurateStopCoordinate {
                  if lastAccurate.data.location_accuracy < sorted[0].data
                    .location_accuracy {
                    self.delegate?
                      .availableLocation([updateServiceData(lastAccurate)])
                  } else {
                    self.lastAccurateStopCoordinate = sorted[0]
                    self.delegate?.availableLocation([sorted[0]])
                  }
                } else {
                  self.lastAccurateStopCoordinate = sorted[0]
                  self.delegate?.availableLocation([sorted[0]])
                }
              } else if let location = self.locationsBuffer.first {
                if let lastAccurate = self.lastAccurateStopCoordinate {
                  if lastAccurate.data.location_accuracy < location.data
                    .location_accuracy {
                    self.delegate?
                      .availableLocation([updateServiceData(lastAccurate)])
                  } else {
                    self.lastAccurateStopCoordinate = location
                    self.delegate?.availableLocation([location])
                  }
                } else {
                  self.lastAccurateStopCoordinate = location
                  self.delegate?.availableLocation([location])
                }
              }
            } else {
              self.lastAccurateStopCoordinate = nil
              self.delegate?.availableLocation(self.locationsBuffer)
            }
          } else {
            self.lastAccurateStopCoordinate = nil
            self.delegate?.availableLocation(self.locationsBuffer)
          }
        }
        locationsBuffer.removeAll()

      case .sendLastKnownLocation:
        guard let lastLocation = lastCoordinate else {
          locationTrackingMode.error("No last location object found")
          return
        }
        delegate?
          .availableLocation([updateServiceData(lastLocation)])

      case .startCriticalTimer:
        criticalTimer.reset(
          timeInterval: Constant.Config.LocationTrackingMode.CriticalMode
            .checkInterval
        )

      case .stopCriticalTimer:
        criticalTimer.suspend()

      case .startActivityTimer:
        guard let activity = currentActivity?.data.type else {
          locationTrackingMode.error("No activity object found")
          return
        }
        activityTimer.reset(
          timeInterval: activity.getActivityValue().time
        )

      case .stopActivityTimer:
        activityTimer.suspend()

      case .startHeartbeatTimer:
        heartbeatTimer.reset(
          timeInterval: Constant.Config.LocationTrackingMode.Heartbeat
            .checkInterval
        )

      case .stopHeartbeatTimer:
        heartbeatTimer.suspend()
    }
  }

  private func mapLocationsToLocationServiceData(_ locations: [CLLocation])
    -> [LocationServiceData] {
      return LocationServiceData.getData(locations)
  }

  private func updateServiceData(_ location: LocationServiceData)
    -> LocationServiceData {
      return LocationServiceData(
        id: UUID().uuidString,
        data: location.data,
        recordedAt: Date()
      )
  }
}

extension LocationTrackingMode: AbstractLocationTrackingMode {
  func setInitialState(_ completionHandler: @escaping () -> Void) {
    serialQueue.async {
      self.startTrackingDate = Date()
      self.currentActivity = nil
      self.lastCoordinate = nil
      self.lastAccurateStopCoordinate = nil
      self.state = TrackingStateMachine.initialState.state
      _ = TrackingStateMachine.initialState.actions.map(self.handleAction(_:))
      locationTrackingMode.log("Set initial mode.")
      completionHandler()
    }
  }

  func setFinalState() {
    serialQueue.async {
      _ = self.state.handleEvent(.final).map(self.handleAction(_:))
      locationTrackingMode.log("Set final mode.")
    }
  }

  func updateActivity(_ activity: ActivityServiceData) {
    serialQueue.async {
      self.currentActivity = activity
      _ = self.state.handleEvent(.activityChanged).map(self.handleAction(_:))
      locationTrackingMode
        .log("Activity changed: \(self.currentActivity.debugDescription)")
    }
  }

  func locationUpdateHandler(_ locations: [CLLocation]) {
    serialQueue.async {
      locationTrackingMode.log("Handling locations: \(locations)")
      let incomingLocationList = self
        .mapLocationsToLocationServiceData(locations)
      if !incomingLocationList.isEmpty {
        self.locationsBuffer += incomingLocationList
        self.lastCoordinate = self.locationsBuffer.last
        locationTrackingMode
          .log("Location buffer, added new location: \(incomingLocationList)")
        locationTrackingMode
          .log("Saved new last known location: \(self.lastCoordinate.debugDescription)")
        _ = self.state.handleEvent(.locationReceived).map(self.handleAction(_:))
      } else {
        locationTrackingMode.log("No valid locations to handle")
      }
    }
  }
}
