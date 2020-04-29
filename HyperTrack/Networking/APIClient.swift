import Foundation

protocol AbstractAPIClient: AnyObject {
  func makeRequest(_ endpoint: APIEndpoint) -> Task<Response>
}

final class APIClient {
  private weak var config: AbstractNetworkConfig?
  private weak var tokenProvider: AuthTokenProvider?
  private var retryCount: Int {
    return config?.network.retryCount ?? Constant.Config.Network.retryCount
  }

  private let internalQueue =
    DispatchQueue(
      label: "com.hypertrack.apiclient.concurrent",
      attributes: .concurrent
    )
  private var internalOpenRequests: [String: Request] = [:]
  private var openRequests: [String: Request] {
    get { return internalQueue.sync { internalOpenRequests } }
    set {
      internalQueue
        .async(flags: .barrier) { self.internalOpenRequests = newValue }
    }
  }

  private weak var detailsProvider: AccountAndDeviceDetailsProvider?
  private var reauthStep: ReAuthorizeStep!

  private var session: URLSession? {
    willSet { session?.finishTasksAndInvalidate() }
  }

  init(
    _ config: AbstractNetworkConfig,
    _ tokenProvider: AuthTokenProvider?,
    _ detailsProvider: AccountAndDeviceDetailsProvider?
  ) {
    let configuration = URLSessionConfiguration.default
    configuration.timeoutIntervalForRequest =
      Constant.Config.Network.timeoutInterval
    session = URLSession(configuration: configuration)
    self.config = config
    self.detailsProvider = detailsProvider
    self.tokenProvider = tokenProvider
    prepareReauth()
  }

  private func prepareReauth() {
    reauthStep = ReAuthorizeStep(
      input: Initialization.Input.ReAuthorize(
        tokenProvider: tokenProvider,
        apiClient: self,
        detailsProvider: detailsProvider
      )
    )
  }
}

extension APIClient: AbstractAPIClient {
  func makeRequest(_ endpoint: APIEndpoint) -> Task<Response> {
    return getTaskForRequest(
      session: session,
      endpoint: endpoint,
      retryCount: retryCount
    ).continueWithTask(
      continuation: { [weak self] (task) -> Task<Response> in
        guard let self = self else { return task }
        if let error = task.error as? SDKError {
          if error.type == .authorizationFailed {
            if endpoint.path != Constant.Config.Network.authenticate {
              return self.reauthStep.execute(input: ()).continueWithTask(
                continuation: { [weak self] (task) -> Task<Response> in
                  guard let self = self else { return task }
                  return self.getTaskForRequest(
                    session: self.session,
                    endpoint: endpoint,
                    retryCount: self.retryCount
                  )
                }
              )
            } else {
              let taskCompletionSource = TaskCompletionSource<Response>()
              let error = SDKError(.invalidToken)
              taskCompletionSource.set(error: error)
              self.tokenProvider?.makeHTAccountInactive(with: error)
              self.cancelAllRequests()
              return taskCompletionSource.task
            }
          } else if error.isTrialPeriodExpired {
            self.tokenProvider?.makeHTAccountInactive(with: error)
            self.cancelAllRequests()
            return task
          } else { return task }
        } else { return task }
      }
    )
  }

  fileprivate func getTaskForRequest(
    session: URLSession?,
    endpoint: APIEndpoint,
    retryCount: Int
  ) -> Task<Response> {
    let id = UUID().uuidString
    guard
      let request = Request(
        id: id,
        session: session,
        endpoint: endpoint,
        retryCount: retryCount
      )
      else { return Task<Response>(Response()) }
    openRequests[id] = request
    let taskCompletionSource = TaskCompletionSource<Response>()
    request.execute { [weak self] response in
      guard let self = self else { return }
      if let error = response.error {
        taskCompletionSource.set(error: error)
      } else { taskCompletionSource.set(result: response) }
      self.openRequests[id] = nil
    }
    return taskCompletionSource.task
  }

  func cancelAllRequests() {
    guard let session = session else { return }
    session.getTasksWithCompletionHandler { data, _, _ in
      for task in data { task.cancel() }
    }
  }
}
