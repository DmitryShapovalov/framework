import CoreLocation.CLLocation
import Foundation

enum Constant {
  static let namespace = "com.hypertrack.sdk.core"
  static let version = "4.0.2-rc.6"

  enum Notification {
    enum Health {
      enum GenerateOutageEvent {
        static let key = "health.generateOutageEvent"
        static let name = Constant.namespace + key
      }
    }

    enum Database {
      enum DataAvailableEvent {
        static let key = "database.dataAvailable"
        static let name = Constant.namespace + key
      }
    }

    enum Transmission {
      enum SendDataEvent {
        static let key = "transmission.events.sendData"
        static let name = Constant.namespace + key
      }

      enum DataSentEvent {
        static let key = "transmission.events.dataSent"
        static let name = Constant.namespace + key
      }
    }

    enum Config {
      enum ConfigChangedEvent {
        static let key = "config.changed"
        static let name = Constant.namespace + key
      }
    }

    enum Activity {
      enum PermissionChangedEvent {
        static let key = "activity.permissionChanged"
        static let name = Constant.namespace + key
      }

      enum ActivityChangedEvent {
        static let key = "activity.changed"
        static let name = Constant.namespace + key
      }
    }

    enum Location {
      enum PermissionChangedEvent {
        static let key = "location.permissionChanged"
        static let name = Constant.namespace + key
      }
    }

    enum Network {
      enum ReachabilityEvent {
        static let key = "network.reachability"
        static let name = Constant.namespace + key
      }
    }

    enum Tracking {
      enum Stopped {
        static let name = HyperTrack.stoppedTrackingNotification.rawValue
      }

      enum Started {
        static let name = HyperTrack.startedTrackingNotification.rawValue
      }

      enum TrackingReason {
        static let key = "tracking.reason.payload"
        static let name = Constant.namespace + key
      }
    }

    enum SDKError {
      enum Unrestorable {
        static let name = HyperTrack.didEncounterUnrestorableErrorNotification
          .rawValue
      }

      enum Restorable {
        static let name = HyperTrack.didEncounterRestorableErrorNotification
          .rawValue
      }
    }

    enum AuthToken {
      enum Inactive {
        static let key = "AuthToken.inactive"
        static let name = Constant.namespace + key
      }

      enum Active {
        static let key = "active.inactive"
        static let name = Constant.namespace + key
      }
    }

    enum Payload { static let errorKey = "hypertrack.error" }
  }

  enum Config {
    enum DataStore { static let dataStoreSuitName = "com.hypertrack.sdk.core" }

    enum Network {
      static let timeoutInterval: Double = 60
      static let retryCount: Int = 3
      static let host: String = "https://live-api.htprod.hypertrack.com"
      static let htBaseUrl = "https://live-api.htprod.hypertrack.com"
      static let events: String = "/events"
      static let customEvents: String = "/custom-events"
      static let registration: String = "/device-info"
      static let deviceSettings: String = "/device-settings"
      static let authenticate: String = "/authenticate"
    }

    enum Dispatch {
      static let frequency: Double = 1
      static let tolerance: Int = 10
      static let debounce: Double = 2
      static let throttle: Double = 1
    }

    enum Transmission { static let batchSize: UInt = 50 }

    enum Services {
      static let types: [ServiceType] = [.location, .health, .activity]

      enum ServiceType: Int, Codable, CustomStringConvertible {
        case location
        case activity
        case health

        var description: String {
          switch self {
            case .location: return "location service"
            case .activity: return "activity service"
            case .health: return "health service"
          }
        }
      }
    }

    enum Location {
      static let onlySignificantLocationUpdates: Bool = false
      static let deferredLocationUpdatesDistance: Double = 0
      static let deferredLocationUpdatesTimeout: Double = 0
      static let backgroundLocationUpdates: Bool = true
      static let distanceFilter: Double = 10
      static let desiredAccuracy: Double = 1
      static let permissionType = 0
      static let showsBackgroundLocationIndicator = false
      static let pausesLocationUpdatesAutomatically = false
      static let coordinatePrecisionPlaces = 6
      static let locationUpdateSettingForStop = (
        distance: kCLDistanceFilterNone,
        time: 300.0
      )
      static let locationUpdateSettingForWalk = (distance: 10.0, time: 20.0)
      static let locationUpdateSettingForRun = (distance: 20.0, time: 20.0)
      static let locationUpdateSettingForCycle = (distance: 20.0, time: 10.0)
      static let locationUpdateSettingForDrive = (distance: 40.0, time: 10.0)
    }

    enum Activity {
      static let checkPermissionInterval: TimeInterval = 1.0
      static let requestActivityInterval: TimeInterval = 7200.0
    }

    enum DeviceSettings { static let delayInterval = 0.0 } /* 300.0*/

    enum Collection {
      static let isFiltering: Bool = false
      static let timeToStopRecordingData: Double = 43200.0
    }

    enum SilentPushNotification {
      static let callbackSendingTimeInterval = 15.0
    }

    enum LocationTrackingMode {
      enum Heartbeat {
        static let checkInterval: TimeInterval = 3300.0
      }

      enum CriticalMode {
        static let checkInterval: TimeInterval = 50.0
      }
    }
  }

  enum ServerKeys {
    enum TrackingState: String {
      case stopTracking = "STOP"
      case startTracking = "START"
    }

    enum DeviceSettings {
      static let tracking = SilentNotification.startTracking
    }

    enum SilentNotification {
      static let notificationData = "hypertrack"
      static let startTracking = "tracking"
    }

    enum Event {
      static let id = "id"
      static let deviceId = "device_id"
      static let source = "source"
      static let sdkVersion = "sdk_version"
      static let type = "type"
      static let data = "data"
      static let recordedAt = "recorded_at"
    }

    enum DeviceInfo {
      static let deviceId = "device_id"
      static let timeZone = "timezone"
      static let networkOperator = "network-operator"
      static let deviceBrand = "device-brand"
      static let deviceModel = "device-model"
      static let osName = "os-name"
      static let osVersion = "os-version"
      static let appPackageName = "app-name"
      static let appVersion = "app-version-number"
      static let sdkVersion = "sdk-version"
      static let recordedAt = "recorded-at"
      static let hasPlayServices = "has-play-services"
      static let deviceName = "name"
      static let deviceMetaData = "device-meta"
      static let osDeviceIdentifier = "os-hardware-identifier"
      static let pushToken = "push_token"
    }
  }

  enum Database {
    static let name = "database.sqlite"

    enum TableName {
      static let onlineEvent = "eventOnline"
      static let customEvent = "eventCustom"
    }
  }

  enum Health {
    static let healthSystemUpdate = "health.key.healthSystemUpdate"
    static let healthServiceOutageGenerationUpdate =
      "health.key.healthServiceOutageGenerationUpdate"
    static let savedLocationPermissionState =
      "health.key.healthSavedLocationPermissionState"
    static let savedActivityPermissionState =
      "health.key.healthSavedActivityPermissionState"
    static let savedStartTrackingReason =
      "health.key.healthSavedStartTrackingReason"

    enum Key {
      static let batteryState = "health.key.batteryState"
    }

    enum Value {
      enum Outage {
        static let key = "outage"
        static let denied = key + ".denied"
        static let disabled = key + ".disabled"
        static let stopped = key + ".stopped"
      }

      enum Resumption {
        static let key = "resumption"
        static let granted = key + ".granted"
        static let started = key + ".started"
      }

      enum Status: String { case update = "status.update" }
    }

    enum Hint {
      enum Tracking: String {
        case pause = "tracking.paused"
        case resume = "tracking.resumed"
        case pushPause = "push.stop"
        case pushResume = "push.start"
        case settingsPause = "settings.stop"
        case settingsResume = "settings.start"
      }

      enum LocationService: String { case disabled = "location.disabled" }

      enum LocationPermission: String {
        case denied = "location.permission_denied"
        case granted = "location.permission_granted"
      }

      enum ActivityService: String {
        case disabled = "activity.disabled"
        case unavailable = "activity.not_supported"
      }

      enum ActivityPermission: String {
        case denied = "activity.permission_denied"
        case granted = "activity.permission_granted"
      }

      enum BatteryLevel: String {
        case low = "battery.low"
        case normal = "battery.back_to_normal"
      }

      enum BatteryState: String {
        case charging = "battery.charging"
        case discharging = "battery.discharging"
      }
    }
  }

  static let lowBatteryValue: Float = 0.2
}

enum EventType: String {
  case activityChange = "activity"
  case locationChange = "location"
  case healthChange = "health"
  case checkIn = "checkin"
}

enum EventCollectionType {
  case online
  case custom

  func tableName() -> String {
    switch self {
      case .online: return Constant.Database.TableName.onlineEvent
      case .custom: return Constant.Database.TableName.customEvent
    }
  }
}
