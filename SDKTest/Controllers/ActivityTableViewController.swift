import CoreMotion
import UIKit

struct ActivityLog {
  private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "dd-MM-yyyy"
    return formatter
  }()

  private let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "hh:mm a"
    return formatter
  }()

  private(set) var headers: [String] = []
  private(set) var logs: [[ViewModel]] = []

  init(activities: [CMMotionActivity]) {
    var values = [String: [CMMotionActivity]]()
    activities.reversed().forEach {
      let key = dateFormatter.string(from: $0.startDate)
      if values[key] == nil { values[key] = [] }
      values[key]?.append($0)
    }
    values.reversed().forEach {
      headers.append($0.key)
      logs.append(
        $0.value.map { ViewModel(activity: $0, formatter: timeFormatter) }
          .filter { $0.activityType.lowercased() != "unsupported" }
      )
    }
  }

  struct ViewModel {
    let time: String
    let activityType: String
    let confidence: String

    init(activity: CMMotionActivity, formatter: DateFormatter) {
      time = formatter.string(from: activity.startDate)
      activityType =
        ActivityServiceData.ActivityType(activity: activity).rawValue
          .capitalized
      confidence = (activity.confidence == .high)
        ? "High" : ((activity.confidence == .medium) ? "Medium" : "Low")
    }
  }
}

class ActivityTableViewController: UITableViewController {
  private let activityManager = CMMotionActivityManager()
  private var values = ActivityLog(activities: [])
  private let queue = OperationQueue()

  override func viewDidLoad() {
    super.viewDidLoad()
    let to = Date()
    let from = to - 86400
    activityManager.startActivityUpdates(to: queue) { _ in }
    activityManager.queryActivityStarting(from: from, to: to, to: queue) {
      [weak self] activities, error in
      DispatchQueue.main.async {
        guard let self = self else { return }
        if let activities = activities, error == nil {
          self.values = ActivityLog(activities: activities)
          self.tableView.reloadData()
        } else {
          let alert = UIAlertController(
            title: "Failed to get activites from OS",
            message: error?.localizedDescription ?? "",
            preferredStyle: UIAlertController.Style.alert
          )
          alert.addAction(
            UIAlertAction(title: "OK", style: .cancel, handler: nil)
          )
          self.present(alert, animated: true, completion: nil)
        }
      }
    }
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  // MARK: Open map

  @IBAction func openMap(_: UIBarButtonItem) {
//    let appDelegate = UIApplication.shared.delegate as? AppDelegate
//    let hyperTrack = appDelegate?.hypertrack
//    guard let hypertrack = hyperTrack else { return }
//    guard
//      let url = URL(
//        string:
//        "https://hypertrack.github.io/atlas/?url=\(Provider.configManager.config.network.host)/locations?device_id=\(hypertrack.deviceID)"
//      )
//      else { return }
//    if #available(iOS 10.0, *) { UIApplication.shared.open(url) } else {
//      // Fallback on earlier versions
//      UIApplication.shared.openURL(url)
//    }
  }

  // MARK: - Table view data source

  override func numberOfSections(in _: UITableView) -> Int {
    // #warning Incomplete implementation, return the number of sections
    return values.logs.count
  }

  override func tableView(_: UITableView, numberOfRowsInSection section: Int)
    -> Int {
      // #warning Incomplete implementation, return the number of rows
      return values.logs[section].count
  }

  override func tableView(
    _ tableView: UITableView,
    cellForRowAt indexPath: IndexPath
  ) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(
      withIdentifier: "reuseIdentifier",
      for: indexPath
    )
    let value = values.logs[indexPath.section][indexPath.row]
    cell.textLabel?.text = value.time
    cell.detailTextLabel?.text =
      "\(value.activityType) [\(value.confidence)]\t\t\t"
    return cell
  }

  override func tableView(_: UITableView, heightForRowAt _: IndexPath)
    -> CGFloat
  { return UITableView.automaticDimension }

  override func tableView(_: UITableView, titleForHeaderInSection section: Int)
    -> String?
  { return values.headers[section] }

  override func tableView(_: UITableView, heightForHeaderInSection _: Int)
    -> CGFloat
  { return 30 }
}
