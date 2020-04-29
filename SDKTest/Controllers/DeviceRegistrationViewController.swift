import UIKit

class DeviceRegistrationViewController: UIViewController {
  var hypertrack: HyperTrack?
  @IBOutlet var deviceNameTextField: UITextField!
  @IBOutlet var sendEventButton: UIButton!
  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var metadataTextView: UITextView!

  override func viewDidLoad() {
    super.viewDidLoad()
//    let appDelegate = UIApplication.shared.delegate as? AppDelegate
//    hypertrack = appDelegate?.hypertrack
    updateUI()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(hyperTrackDidEncounterError(notification:)),
      name: HyperTrack.didEncounterUnrestorableErrorNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(hyperTrackDidEncounterError(notification:)),
      name: HyperTrack.didEncounterRestorableErrorNotification,
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
    metadataTextView.layer.borderColor = borderColor.cgColor
    metadataTextView.layer.borderWidth = 1.0
    metadataTextView.layer.cornerRadius = 5.0
    deviceNameTextField.layer.borderColor = borderColor.cgColor
    deviceNameTextField.layer.borderWidth = 1.0
    deviceNameTextField.layer.cornerRadius = 5.0
    setDoneOnKeyboard()
    metaDataUI()
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
    metadataTextView.inputAccessoryView = keyboardToolbar
    deviceNameTextField.inputAccessoryView = keyboardToolbar
  }

  @objc func dismissKeyboard() { view.endEditing(true) }

  private func metaDataUI() {
    title = "Device data"
    deviceNameTextField.placeholder = "Device Name"
    sendEventButton.setTitle("SEND METADATA", for: .normal)
  }

  @IBAction func sendButtonPressed(_: UIButton) {
    view.endEditing(true)
    let text = deviceNameTextField.text
    sendDeviceMetaData(forText: text)
  }

  private func sendDeviceMetaData(forText text: String?) {
    toShowActivityIndicator(toShow: true)
    let metaString = metadataTextView.text
    var json: [String: String]?
    if let metaString = metaString, !metaString.isEmpty,
      let data = metaString.data(using: .utf8) {
      do {
        json = try JSONSerialization.jsonObject(
          with: data,
          options: .allowFragments
        ) as? [String: String]
      } catch {
        toShowActivityIndicator(toShow: false)
        showAlert(withTitle: "Error", withMessage: "Invalid Json")
        return
      }
    }
    guard let name = text else {
      showAlert(withTitle: "Error", withMessage: "Invalid Name")
      return
    }
    guard let JSON = json else {
      showAlert(withTitle: "Error", withMessage: "Invalid JSON")
      return
    }
    if let metadata = HyperTrack.Metadata(dictionary: JSON) {
      hypertrack?.setDeviceMetadata(metadata)
    } else {
      showAlert(
        withTitle: "Error",
        withMessage: "Cannot serialize metadata to JSON"
      )
    }

    hypertrack?.setDeviceName(name)
    toShowActivityIndicator(toShow: false)
    showAlert(withTitle: "Success", withMessage: "Device metadata sent")
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
    if let error = notification.hyperTrackTrackingError() {
      showAlert(
        withTitle: "Error",
        withMessage:
        String(describing: error)
      )
    }
  }

  deinit { NotificationCenter.default.removeObserver(self) }
}
