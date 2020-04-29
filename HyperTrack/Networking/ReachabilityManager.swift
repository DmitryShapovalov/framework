import Foundation

private typealias ReachabilityEvent = Constant.Notification.Network
  .ReachabilityEvent

protocol AbstractReachabilityManager: AnyObject {
  var isReachable: Bool { get }
}

final class ReachabilityManager: AbstractReachabilityManager {
  fileprivate weak var config: AbstractNetworkConfig?
  fileprivate weak var eventBus: AbstractEventBus?

  private(set) var isReachable: Bool = false {
    didSet {
      eventBus?.post(
        name: ReachabilityEvent.name,
        userInfo: [ReachabilityEvent.key: isReachable]
      )
    }
  }

  private(set) var networkType: NetworkType = .unavailable {
    didSet {
      switch networkType {
        case .unavailable: isReachable = false
        default: isReachable = true
      }
    }
  }

  enum NetworkType: String {
    case wifi = "WiFi"
    case wwan = "WWAN"
    case unavailable = "Unavailable"
  }

  init(_ config: AbstractNetworkConfig?, _ eventBus: AbstractEventBus?) {
    self.config = config
    self.eventBus = eventBus
  }

  @objc fileprivate func reachabilityStatusChanged(_ sender: NSNotification) {

  }

  fileprivate func updateInterfaceWithCurrent() {

  }

  deinit {  }
}
