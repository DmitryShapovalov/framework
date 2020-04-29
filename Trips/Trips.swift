import Foundation
import UIKit

public class Trips {
  public static func pushTripsFlow(
    navigationController: UINavigationController?,
    config: Configuration
  ) {
    guard let navigationController = navigationController else {
      fatalError(
        "Can't push a view controller without a current navigation controller"
      )
    }
    let apiClient = APIClient(config: config)
    let sceneCoordinator = SceneCoordinator(
      navigationCntroller: navigationController
    )
    let tripListViewModel = TripListViewModel(
      apiClient: apiClient,
      coordinator: sceneCoordinator
    )
    let firstScene = Scene.tripsList(tripListViewModel)
    sceneCoordinator.transition(to: firstScene, type: .push)
  }
}
