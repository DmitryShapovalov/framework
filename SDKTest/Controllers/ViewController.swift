import Foundation
import Trips
import UIKit

class ViewController: UIViewController {
  var hypertrack: HyperTrack?
  @IBOutlet fileprivate var statusLabel: HTCopyableLabel!
  @IBOutlet fileprivate var versionLabel: UILabel! {
    didSet { versionLabel.text = "Version \(getVersion())" }
  }

  @IBOutlet var initializeHistoryTextView: UITextView! {
    didSet {
      initializeHistoryTextView.layer.cornerRadius = cornerRadius
      initializeHistoryTextView.layer.borderColor = borderColor
      initializeHistoryTextView.layer.borderWidth = borderWidth
    }
  }

  @IBOutlet var syncButton: UIButton!
  @IBOutlet fileprivate var trackingButton: UIButton!
  fileprivate var greenColor: UIColor {
    return UIColor(
      red: CGFloat(20.0 / 255.0),
      green: CGFloat(151.0 / 255.0),
      blue: CGFloat(57.0 / 255.0),
      alpha: 1.0
    )
  }

  fileprivate var enabled = false {
    didSet {
      trackingButton.setTitle(
        enabled ? "STOP TRACKING" : "START TRACKING",
        for: .normal
      )
      trackingButton.setTitleColor(
        enabled ? UIColor.red : greenColor,
        for: .normal
      )
    }
  }

  fileprivate let timer: GCDRepeatingTimer = GCDRepeatingTimer(
    timeInterval: Constant.Config.DeviceSettings.delayInterval
  )

  override func viewDidLoad() {
    super.viewDidLoad()
//    let appDelegate = UIApplication.shared.delegate as? AppDelegate
//    hypertrack = appDelegate?.hypertrack
    statusLabel.copyableText = hypertrack?.deviceID ?? "None"
    statusLabel.text = statusLabel.copyableText
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(isTracking),
      name: UIApplication.didBecomeActiveNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(isTracking),
      name: HyperTrack.startedTrackingNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(isTracking),
      name: HyperTrack.stoppedTrackingNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(hyperTrackDidEncounterError(notification:)),
      name: HyperTrack.didEncounterRestorableErrorNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(hyperTrackDidEncounterError(notification:)),
      name: HyperTrack.didEncounterUnrestorableErrorNotification,
      object: nil
    )
    timer.eventHandler = { [weak self] in
      guard let self = self else { return }
      DispatchQueue.main.async {
        self.syncButton.isEnabled = true
        self.syncButton.alpha = 1.0
      }
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    isTracking()
  }

  @objc private func isTracking() { enabled = hypertrack?.isRunning ?? false }
  @objc private func hyperTrackDidEncounterError(notification: Notification) {
    initializeHistoryTextView.text.append(
      "[\(Date())]: \(String(describing: notification.hyperTrackTrackingError())) \n"
    )
    isTracking()
  }

  fileprivate func getVersion() -> String {
    guard
      let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
      as? String,
      let buildNum = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
      else { return "NA" }
    return "\(appVersion) (\(buildNum))"
  }

  @IBAction func openTrip(sender: UIButton) {
//    Trips.pushTripsFlow(
//      navigationController: navigationController,
//      config: BaseURLConfigurator.mapBaseHyperTrackConfig()
//    )
//    hypertrack?.syncDeviceSettings()
  }

  @IBAction func resumeTrackingButtonClicked() {
    if enabled {
      enabled = false
      hypertrack?.stop()
    } else {
      enabled = true
      hypertrack?.start()
    }
  }

  @IBAction func syncButtonClicked(_: UIButton) {
    hypertrack?.syncDeviceSettings()
    syncButton.isEnabled = false
    syncButton.alpha = 0.5
    timer.reset(
      timeInterval: Constant.Config.DeviceSettings.delayInterval
    )
  }

  deinit { NotificationCenter.default.removeObserver(self) }
}
