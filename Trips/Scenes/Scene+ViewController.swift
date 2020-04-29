import UIKit

extension Scene {
  func viewController() -> UIViewController {
    switch self {
      case let .tripsList(viewModel):
        var tripListViewController = TripListScreenViewController()
        tripListViewController.bindViewModel(to: viewModel)
        return tripListViewController
      case let .createTrip(viewModel):
        var editTripViewController = EditTripViewController()
        editTripViewController.bindViewModel(to: viewModel)
        return editTripViewController
      case let .openMap(viewModel):
        var mapViewController = MapViewController()
        mapViewController.bindViewModel(to: viewModel)
        return mapViewController
      case let .getAlert(title, body):
        let alert = UIAlertController(
          title: title,
          message: body,
          preferredStyle: UIAlertController.Style.alert
        )
        alert
          .addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        return alert
      case let .displayTrip(viewModel):
        var displayTripViewController = DisplayTripViewController()
        displayTripViewController.bindViewModel(to: viewModel)
        return displayTripViewController
      case let .shareTrip(url):
        let linkString = "\(NSLocalizedString("", comment: "")) \(url)"
        let actionSheet = UIActivityViewController(
          activityItems: [linkString],
          applicationActivities: nil
        )
        actionSheet.excludedActivityTypes = [.saveToCameraRoll]
        return actionSheet
      case let .openURLShareList(share_url, embed_url, complition):
        let actionSheetController: UIAlertController = UIAlertController(
          title: "Please select",
          message: nil,
          preferredStyle: .actionSheet
        )
        let cancelActionButton = UIAlertAction(
          title: "Cancel",
          style: .cancel
        ) {
          _ in
        }
        let embedURLActionButton = UIAlertAction(
          title: "Embed URL",
          style: .default
        ) { _ in complition(embed_url) }
        let shareURLActionButton = UIAlertAction(
          title: "Share URL",
          style: .default
        ) { _ in complition(share_url) }
        actionSheetController.addAction(cancelActionButton)
        actionSheetController.addAction(embedURLActionButton)
        actionSheetController.addAction(shareURLActionButton)
        return actionSheetController
    }
  }
}
