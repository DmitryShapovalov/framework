import Foundation

protocol AbstractDispatch: AnyObject { func dispatch() }

final class Dispatch {
  private weak var eventBus: AbstractEventBus?
  private var type: Config.Dispatch.DispatchType
  private var strategy: AbstractDispatchStrategy?
  private weak var config: AbstractDispatchConfig?
  private weak var transmission: AbstractPipeline?
  private var context: AbstractDispatchStrategyContext?
  private var reachability: AbstractReachabilityManager?
  private var isNewDataAvailable: Bool

  init(
    _ reachability: AbstractReachabilityManager?,
    _ eventBus: AbstractEventBus?,
    _ config: AbstractDispatchConfig?,
    _ context: AbstractDispatchStrategyContext?,
    _ transmission: AbstractPipeline?
  ) {
    self.eventBus = eventBus
    self.config = config
    self.context = context
    self.transmission = transmission
    self.reachability = reachability
    isNewDataAvailable = true
    type = config?.dispatch.type ?? .manual
    strategy = context?.getDispatchStrategy(self, config: config)
    self.eventBus?.addObserver(
      self,
      selector: #selector(reachabilityChanged(_:)),
      name: Constant.Notification.Network.ReachabilityEvent.name
    )
    self.eventBus?.addObserver(
      self,
      selector: #selector(dataAvailable(_:)),
      name: Constant.Notification.Database.DataAvailableEvent.name
    )
    self.eventBus?.addObserver(
      self,
      selector: #selector(transmissionDone(_:)),
      name: Constant.Notification.Transmission.DataSentEvent.name
    )
    self.eventBus?.addObserver(
      self,
      selector: #selector(authTokenInactive(_:)),
      name: Constant.Notification.AuthToken.Inactive.name
    )
  }

  @objc private func dataAvailable(_: Notification) {
    guard let isReachable = reachability?.isReachable else { return }
    isNewDataAvailable = true
    if isReachable {
      strategy?.start()
      logDispatch
        .log("Started dispatch strategy for reason: new event is available.")
    } else {
      logDispatch
        .log("Can't start dispatch strategy, when reachability is: \(isReachable)")
    }
  }

  @objc private func transmissionDone(_: Notification) {
    strategy?.stop()
    isNewDataAvailable = false
    logDispatch
      .log("Stopped dispatch strategy for reason: transmission is done.")
  }

  @objc private func authTokenInactive(_: Notification) {
    strategy?.stop()
    isNewDataAvailable = false
    logDispatch
      .log("Stopped dispatch strategy for reason: auth token inactive.")
  }

  @objc private func reachabilityChanged(_: Notification) {
    guard let isReachable = reachability?.isReachable else { return }
    logDispatch.log("Reachability was changed with state: \(isReachable)")
    if !isReachable {
      strategy?.stop()
      logDispatch
        .log("Stopped dispatch strategy for reason: reachability false.")
    } else if isNewDataAvailable {
      strategy?.start()
      logDispatch
        .log("Started dispatch strategy for reason: reachability was changed | New data is available")
    }
  }
}

extension Dispatch: AbstractDispatch {
  func dispatch() { transmission?.execute(completionHandler: nil) }
}

protocol AbstractDispatchStrategy {
  func start()
  func stop()
}

protocol AbstractDispatchStrategyContext {
  func getDispatchStrategy(
    _ dispatch: AbstractDispatch,
    config: AbstractDispatchConfig?
  ) -> AbstractDispatchStrategy?
}

final class DispatchStrategyContext: AbstractDispatchStrategyContext {
  func getDispatchStrategy(
    _ dispatch: AbstractDispatch,
    config: AbstractDispatchConfig?
  ) -> AbstractDispatchStrategy? {
    guard let config = config else { return nil }
    switch config.dispatch.type {
      case .timer:
        return TimerDispatchStrategy(dispatch: dispatch, config: config)
      default: return nil
    }
  }
}

final class TimerDispatchStrategy: AbstractDispatchStrategy {
  weak var dispatch: AbstractDispatch?
  var timer: Repeater?
  var debouncer: Debouncer?

  var frequency: Double {
    return config?.dispatch.frequency ?? Constant.Config.Dispatch.frequency
  }

  var debounce: Double {
    return config?.dispatch.debounce ?? Constant.Config.Dispatch.debounce
  }

  var tolerance: Int {
    return config?.dispatch.tolerance ?? Constant.Config.Dispatch.tolerance
  }

  fileprivate weak var config: AbstractDispatchConfig?

  init(dispatch: AbstractDispatch?, config: AbstractDispatchConfig?) {
    self.dispatch = dispatch
    self.config = config
    timer = Repeater(
      interval: Repeater.Interval.seconds(frequency),
      mode: .infinite,
      queue: DispatchQueue.global(qos: .background),
      tolerance: .seconds(tolerance)
    ) { [weak self] _ in self?.dispatch?.dispatch() }
    debouncer = Debouncer(
      Repeater.Interval.seconds(debounce),
      callback: { [weak self] in self?.timer?.start() }
    )
  }

  func start() { debouncer?.call() }

  func stop() { timer?.pause() }

  deinit { timer?.removeAllObservers(thenStop: true) }
}
