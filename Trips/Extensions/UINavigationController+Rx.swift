import RxCocoa
import RxSwift
import UIKit

extension UINavigationController {
  public typealias Delegate = UINavigationControllerDelegate
}

open class RxNavigationControllerDelegateProxy: DelegateProxy<
  UINavigationController, UINavigationControllerDelegate
>, DelegateProxyType, UINavigationControllerDelegate {
  /// Typed parent object.
  public private(set) weak var navigationController: UINavigationController?
  /// - parameter navigationController: Parent object for delegate proxy.
  public init(navigationController: ParentObject) {
    self.navigationController = navigationController
    super.init(
      parentObject: navigationController,
      delegateProxy: RxNavigationControllerDelegateProxy.self
    )
  }

  // Register known implementations
  public static func registerKnownImplementations() {
    register { RxNavigationControllerDelegateProxy(navigationController: $0) }
  }
}
