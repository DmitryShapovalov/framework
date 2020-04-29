import UIKit

class TripMarkerViewController: UIViewController {
  var hypertrack: HyperTrack?
  @IBOutlet var textView: UITextView!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!

  override func viewDidLoad() {
    super.viewDidLoad()
//    let appDelegate = UIApplication.shared.delegate as? AppDelegate
//    hypertrack = appDelegate?.hypertrack
    updateUI()
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
  }

  private func updateUI() {
    let borderColor = UIColor(
      red: 204 / 255.0,
      green: 204 / 255.0,
      blue: 204 / 255.0,
      alpha: 1.0
    )
    textView.layer.borderColor = borderColor.cgColor
    textView.layer.borderWidth = 1.0
    textView.layer.cornerRadius = 5.0
    setDoneOnKeyboard()
    title = "Custom event"
  }

  func setDoneOnKeyboard() {
    let keyboardToolbar = UIToolbar()
    keyboardToolbar.sizeToFit()
    let flexBarButton = UIBarButtonItem(
      barButtonSystemItem: .flexibleSpace,
      target: nil,
      action: nil
    )
    let doneBarButton = UIBarButtonItem(
      barButtonSystemItem: .done,
      target: self,
      action: #selector(dismissKeyboard)
    )
    keyboardToolbar.items = [flexBarButton, doneBarButton]
    textView.inputAccessoryView = keyboardToolbar
  }

  @objc func dismissKeyboard() { view.endEditing(true) }

  @IBAction func sendCustomEvent(_: UIButton) {
    toShowActivityIndicator(toShow: true)
    let metaString = textView.text
    var json: [String: Any]?
    if let metaString = metaString, !metaString.isEmpty,
      let data = metaString.data(using: .utf8) {
      do {
        json = try JSONSerialization.jsonObject(
          with: data,
          options: .allowFragments
        ) as? [String: Any]
      } catch {
        toShowActivityIndicator(toShow: false)
        showAlert(withTitle: "Error", withMessage: "Invalid Json")
        return
      }
    }
    if let object = json {
      if let metadata = HyperTrack.Metadata(dictionary: object) {
        hypertrack?.addTripMarker(metadata)
      } else {
        showAlert(
          withTitle: "Error",
          withMessage: "Cannot serialize metadata to JSON"
        )
      }
      toShowActivityIndicator(toShow: false)
      showAlert(withTitle: "Success", withMessage: "Custom event added to queue")
    } else {
      showAlert(withTitle: "Error", withMessage: "Empty metadata")
      toShowActivityIndicator(toShow: false)
    }
  }

  private func toShowActivityIndicator(toShow: Bool) {
    if toShow == true {
      activityIndicator.startAnimating()
      view.isUserInteractionEnabled = false
    } else {
      activityIndicator.stopAnimating()
      view.isUserInteractionEnabled = true
    }
  }

  private func showAlert(withTitle title: String, withMessage message: String) {
    DispatchQueue.main.async {
      let alert = UIAlertController(
        title: title,
        message: message,
        preferredStyle: .alert
      )
      alert.addAction(
        UIAlertAction(
          title: "OK",
          style: UIAlertAction.Style.default,
          handler: nil
        )
      )
      self.present(alert, animated: true, completion: nil)
    }
  }

  @objc private func hyperTrackDidEncounterError(notification: Notification) {
    showAlert(
      withTitle: "Error",
      withMessage:
      "\(String(describing: notification.hyperTrackTrackingError()))"
    )
  }

  deinit { NotificationCenter.default.removeObserver(self) }
}
