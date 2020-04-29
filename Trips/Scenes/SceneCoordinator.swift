import RxCocoa
import RxSwift
import UIKit

class SceneCoordinator: SceneCoordinatorType {
  fileprivate var navigationController: UINavigationController
  required init(navigationCntroller: UINavigationController) {
    navigationController = navigationCntroller
  }

  static func actualViewController(for viewController: UIViewController)
    -> UIViewController {
      if let navigationController = viewController as? UINavigationController {
        return navigationController.viewControllers.first!
      } else { return viewController }
  }

  @discardableResult func transition(to scene: Scene, type: SceneTransitionType)
    -> Completable {
      let subject = PublishSubject<Void>()
      let viewController = scene.viewController()
      switch type {
        case .push:
          _ = navigationController.rx.delegate.sentMessage(
            #selector(UINavigationControllerDelegate
              .navigationController(_:didShow:animated:))
          ).map { _ in }.bind(to: subject)
          navigationController
            .pushViewController(viewController, animated: true)
        case .modal:
          navigationController.present(viewController, animated: true) {
            subject.onCompleted()
          }
      }
      return subject.asObservable().take(1).ignoreElements()
  }

  @discardableResult func pop(animated: Bool) -> Completable {
    let subject = PublishSubject<Void>()
    if let _ = navigationController.presentingViewController {
      // dismiss a modal controller
      navigationController.dismiss(animated: animated) { subject.onCompleted() }
    } else {
      // navigate up the stack
      // one-off subscription to be notified when pop complete
      _ = navigationController.rx.delegate.sentMessage(
        #selector(UINavigationControllerDelegate
          .navigationController(_:didShow:animated:))
      ).map { _ in }.bind(to: subject)
      guard navigationController.popViewController(animated: animated) != nil
        else { fatalError("can't navigate back from \(navigationController)") }
    }
    return subject.asObservable().take(1).ignoreElements()
  }
}
