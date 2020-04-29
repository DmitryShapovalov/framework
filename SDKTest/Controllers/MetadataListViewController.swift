import UIKit

class MetadataListViewController: UITableViewController {
  override func viewDidLoad() { super.viewDidLoad() }

  override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
    return 2
  }

  override func tableView(_: UITableView, cellForRowAt indexPath: IndexPath)
    -> UITableViewCell {
      let cell = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
      switch indexPath.row {
        case 0: cell.textLabel?.text = "Device registration"
        case 1: cell.textLabel?.text = "Custom event"
        default: return cell
      }
      return cell
  }

  override func tableView(
    _ tableView: UITableView,
    didSelectRowAt indexPath: IndexPath
  ) {
    tableView.deselectRow(at: indexPath, animated: false)
    switch indexPath.row {
      case 0:
        performSegue(
          withIdentifier: "DeviceRegistrationViewControllerSegue",
          sender: nil
        )
      case 1:
        performSegue(
          withIdentifier: "CustomEventViewControllerSegue",
          sender: nil
        )
      default: return
    }
  }
}
