import Foundation

protocol AbstractSettings: AnyObject {
  func getSettings()
}

final class DeviceSettings: AbstractSettings {
  fileprivate weak var appState: AbstractAppState?
  fileprivate weak var apiClient: AbstractAPIClient?
  fileprivate weak var eventBus: AbstractEventBus?
  fileprivate weak var serviceManager: AbstractServiceManager?
  fileprivate weak var initializationPipeline: InitializationPipeline?
  fileprivate let serialQueue = DispatchQueue(label: "com.hypertrack.ds.serial")

  fileprivate var lastReceivedDeviceSettingsDate: Date?
  fileprivate var delayInterval: TimeInterval = Constant.Config.DeviceSettings
    .delayInterval

  fileprivate let stepSettings: AbstractPipelineStep<Void, Response>
  fileprivate let stepTokenAuth: AbstractPipelineStep<Void, Bool>

  init(
    _ appState: AbstractAppState?,
    _ apiClient: AbstractAPIClient?,
    _ eventBus: AbstractEventBus?,
    _ tokenProvider: AuthTokenProvider?,
    _ serviceManager: AbstractServiceManager?,
    _ initializationPipeline: InitializationPipeline?
  ) {
    self.appState = appState
    self.apiClient = apiClient
    self.eventBus = eventBus
    self.serviceManager = serviceManager
    self.initializationPipeline = initializationPipeline
    stepSettings = DeivceSettingsStep(input: apiClient)
    stepTokenAuth = AuthorizationTokenCheckStep(
      input: ReAuthorizeStep(
        input: Initialization.Input.ReAuthorize(
          tokenProvider: tokenProvider,
          apiClient: apiClient,
          detailsProvider: appState
        )
      )
    )
  }

  func getSettings() {
    if lastReceivedDeviceSettingsDate == nil {
      lastReceivedDeviceSettingsDate = Date()
      settingsServerRequest()
    } else if let date = lastReceivedDeviceSettingsDate,
      date.addingTimeInterval(delayInterval) <= Date() {
      lastReceivedDeviceSettingsDate = Date()
      settingsServerRequest()
    } else {
      logSettings.info(
        "Attempt to reuse the \(#function) before the delay time is over. Last call was: \(String(describing: lastReceivedDeviceSettingsDate))"
      )
    }
  }

  private func settingsServerRequest() {
    logSettings.info("Executing device settings.")
    setState(.executing)
    stepTokenAuth.execute(input: ())
      .continueWithTask(
        Executor.queue(serialQueue),
        continuation: { [unowned self] (task) -> Task<Response> in
          switch task.mapTaskToResult() {
            case .success:
              return self.stepSettings.execute(input: ())
            case let .failure(error):
              logSettings.log("Executed \(#function) with error: \(error)")
              throw error
          }
        }
      ).continueWith(continuation: { [weak self] (task) -> Void in
        guard let self = self else { return }
        if let response = task.result {
          self.receivedDeviceSettings(response)
          self.setState(.success)
        } else if let error = task.error {
          logSettings.error(
            "Failed to execute the request: \(ApiRouter.deviceSettings) with error: \(error.localizedDescription)"
          )
          self.setState(.failure(error))
        }
      })
  }

  private func receivedDeviceSettings(_ response: Response) {
    guard let data = response.data else { return }
  }
}

extension DeviceSettings: PipelineLogging {
  func setState(
    _ type: Pipeline.State,
    file: String = #file,
    function: String = #function,
    line: Int = #line
  ) { log(type, file: file, function: function, line: line) }
}
