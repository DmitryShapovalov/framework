import Foundation

final class InitializationPipeline {
  var isExecuting: Bool = false

  private var config: AbstractConfig
  private let serialQueue = DispatchQueue(label: "com.hypertrack.ip.serial")

  private let stepPermission: AbstractPipelineStep<Void, Bool>
  private let stepRegistration: AbstractPipelineStep<Void, Bool>
  private let stepTokenAuth: AbstractPipelineStep<Void, Bool>

  private weak var appState: AbstractAppState?
  private weak var eventBus: AbstractEventBus?
  private weak var tokenProvider: AuthTokenProvider?
  private weak var dataStore: AbstractReadWriteDataStore?
  private weak var serviceManager: AbstractServiceManager?
  private weak var errorHandler: AbstractErrorHandler?

  init(
    _ config: AbstractConfig,
    _ serviceManager: AbstractServiceManager?,
    _ appState: AbstractAppState?,
    _ eventBus: AbstractEventBus?,
    _ dataStore: AbstractReadWriteDataStore?,
    _ tokenProvider: AuthTokenProvider?,
    _ errorHandler: AbstractErrorHandler?
  ) {
    self.config = config
    self.serviceManager = serviceManager
    self.appState = appState
    self.eventBus = eventBus
    self.dataStore = dataStore
    self.tokenProvider = tokenProvider
    self.errorHandler = errorHandler

    stepPermission = PermissionStep(serviceManager: serviceManager)
    stepRegistration = InitDeviceRegistrationEntity(
      apiClient: Provider.apiClient,
      appState: Provider.appState
    )
    stepTokenAuth = AuthorizationTokenCheckStep(
      input: ReAuthorizeStep(
        input: Initialization.Input.ReAuthorize(
          tokenProvider: tokenProvider,
          apiClient: Provider.apiClient,
          detailsProvider: Provider.appState
        )
      )
    )
  }
}

extension InitializationPipeline: InitializeAbstractPipeline {
  func initializeSDK() {
    guard let appState = self.appState, let serviceManager = self.serviceManager else { return }
    logInitialization.log(
      "Initializimg SDK with userTrackingBehaviour: \(appState.userTrackingBehaviour)"
    )
    if !appState.getPublishableKey().isEmpty, !appState.getPushNotificationDeviceToken().isEmpty, appState.currentSessionDeviceInfo?.pushToken != appState.getPushNotificationDeviceToken() {
      updateDeviceInfo()
    } else if !appState.getPublishableKey().isEmpty, appState.currentSessionDeviceInfo?.deviceId != appState.getDeviceId() {
      updateDeviceInfo()
    }
    if appState.userTrackingBehaviour == .resumed, serviceManager.numberOfRunningServices() != serviceManager.numberOfServices() {
      startInitialize()
    }
    else {
      let numberOfRunningServices = serviceManager.numberOfRunningServices()
      logInitialization.log(
        """
        Attempt to start Initialize.
        Current user intent: \(appState.userTrackingBehaviour)
        Current running service count: \(numberOfRunningServices)
        """
      )
    }
  }

  fileprivate func startInitialize() {
    execute(for: .trackingStart) { [weak self] error in
      guard let self = self, let error = error, let appState = self.appState,
        let errorHandler = self.errorHandler
        else { return }
      logInitialization.log(
        "Executing startInitialize with userTrackingBehaviour: \(appState.userTrackingBehaviour)"
      )
      errorHandler.handleError(error)
      self.eventBus?.post(
        name: Constant.Notification.Health.GenerateOutageEvent.name,
        userInfo: [Constant.Notification.Health.GenerateOutageEvent.key: error]
      )
    }
  }

  func startTracking(for reason: TrackingReason) {
    guard let appState = self.appState,
      let serviceManager = self.serviceManager, let dataStore = self.dataStore
      else { return }
    guard
      serviceManager.numberOfRunningServices()
      != serviceManager.numberOfServices()
      else {
        logTracking.log("Attempt to start tracking when tracking is started")
        return
    }
    logTracking.log("Starting tracking with reason: \(reason.toString())")
    appState.userTrackingBehaviour = .resumed
    dataStore.set(
      reason.rawValue,
      forKey: Constant.Health.savedStartTrackingReason
    )
    execute(for: reason) { [weak self] error in
      guard let self = self, let error = error,
        let errorHandler = self.errorHandler
        else { return }
      errorHandler.handleError(error)
      self.eventBus?.post(
        name: Constant.Notification.Health.GenerateOutageEvent.name,
        userInfo: [Constant.Notification.Health.GenerateOutageEvent.key: error]
      )
    }
  }

  func stopTracking(for reason: TrackingReason) {
    guard let appState = self.appState,
      let serviceManager = self.serviceManager, let eventBus = self.eventBus
      else { return }
    appState.userTrackingBehaviour = .paused
    guard
      serviceManager.numberOfRunningServices()
      == serviceManager.numberOfServices()
      else {
        logTracking.log("Attempt to stop tracking when tracking is stopped")
        return
    }
    logTracking.log("Stopping tracking, reason: \(reason.toString())")
    serviceManager.stopAllServices()
    eventBus.post(
      name: Constant.Notification.Tracking.Stopped.name,
      userInfo: [Constant.Notification.Tracking.TrackingReason.key: reason]
    )
  }

  func execute(
    for reason: TrackingReason,
    completionHandler: ((SDKError?) -> Void)?
  ) {
    logInitialization.log("Executing InitializationPipeline")
    setState(.executing)
    stepPermission.execute(input: ()).continueWith(
      Executor.queue(serialQueue),
      continuation: { [weak self] task in
        guard let self = self, var appState = self.appState,
          let serviceManager = self.serviceManager, let eventBus = self.eventBus
          else { return }
        switch task.mapTaskToResult() {
          case .success:
            if appState.userTrackingBehaviour == .resumed {
              appState.resumptionDate = Date()
              serviceManager.startAllServices()
              serviceManager.checkPermissions()
              eventBus.post(
                name: Constant.Notification.Tracking.Started.name,
                userInfo: [
                  Constant.Notification.Tracking.TrackingReason.key: reason
                ]
              )
            }
            completionHandler?(nil)
            logInitialization
              .log("Executed InitializationPipeline with success")
            self.setState(.success)
          case let .failure(error):
            self.setState(.failure(error))
            logInitialization.log(
              "Executed InitializationPipeline with error: \(error)"
            )
            completionHandler?(error)
            throw error
        }
      }
    )
  }
}

extension InitializationPipeline {
  func updateDeviceInfo() {
    logInitialization.log("Executing updateDeviceInfo")
    setState(.executing)
    stepTokenAuth.execute(input: ())
      .continueWithTask(
        Executor.queue(serialQueue),
        continuation: { [unowned self] (task) -> Task<Bool> in
          switch task.mapTaskToResult() {
            case .success:
              return self.stepRegistration.execute(input: ())
            case let .failure(error):
              logInitialization
                .log("Executed \(#function) with error: \(error)")
              throw error
          }
        }
      ).continueWith(
        Executor.queue(serialQueue),
        continuation: { [unowned self] task in
          switch task.mapTaskToResult() {
            case .success:
              logInitialization.log("Executed updateDeviceInfo success")
              self.setState(.success)
            case let .failure(error):
              logInitialization
                .log("Executed \(#function) with error: \(error)")
              self.setState(.failure(error))
              throw error
          }
        }
      )
  }
}

extension InitializationPipeline {
  func preInit() {
    _ = Provider.transmissionPipeline
    _ = Provider.dispatch
    _ = Provider.collectionPipeline
  }
}

extension Task {
  func mapTaskToResult() -> Result<TResult, SDKError> {
    if let error = error as? SDKError {
      return .failure(error)
    } else if let result = result { return .success(result) } else {
      return .failure(SDKError(.unknown))
    }
  }
}
