import UIKit

public enum ServerOptions: Int {
  case live = 0
  case devpoc = 1
  case other = 2
}

let cornerRadius: CGFloat = 4
let borderWidth: CGFloat = 1
let borderColor = UIColor.gray.cgColor

class ChangeBaseURLViewController: UIViewController {
  fileprivate let configurator: BaseURLConfigurator = BaseURLConfigurator()

  @IBOutlet var deviceNameTextfield: UITextField! {
    didSet {
      deviceNameTextfield.layer.cornerRadius = cornerRadius
      deviceNameTextfield.layer.borderColor = borderColor
      deviceNameTextfield.layer.borderWidth = borderWidth
      deviceNameTextfield.returnKeyType = .done
    }
  }

  @IBOutlet var hostURLTextView: UITextView! {
    didSet {
      hostURLTextView.layer.cornerRadius = cornerRadius
      hostURLTextView.layer.borderColor = borderColor
      hostURLTextView.layer.borderWidth = borderWidth
      hostURLTextView.returnKeyType = .done
    }
  }

  @IBOutlet var publicKeyTextView: UITextView! {
    didSet {
      publicKeyTextView.layer.cornerRadius = cornerRadius
      publicKeyTextView.layer.borderColor = borderColor
      publicKeyTextView.layer.borderWidth = borderWidth
      publicKeyTextView.returnKeyType = .done
    }
  }

  @IBOutlet var btSetNew: UIButton! {
    didSet {
      btSetNew.layer.cornerRadius = cornerRadius
      btSetNew.layer.borderColor = borderColor
      btSetNew.layer.borderWidth = borderWidth
    }
  }

  @IBOutlet var btSetDeviceName: UIButton! {
    didSet {
      btSetDeviceName.layer.cornerRadius = cornerRadius
      btSetDeviceName.layer.borderColor = borderColor
      btSetDeviceName.layer.borderWidth = borderWidth
    }
  }

  @IBOutlet var activityIndicator: UIActivityIndicatorView!
  @IBOutlet var serverSwitcher: UISegmentedControl!

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
    updateText()
    serverSwitcher.selectedSegmentIndex =
      configurator.getCurrentBaseURLIndex().rawValue
    hideKeyboardWhenTappedAround()
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

  @IBAction func changeServerHandler(_ sender: UISegmentedControl) {
    let sModel = configurator.getURLWith(
      index: ServerOptions(rawValue: sender.selectedSegmentIndex)!
    )
    hostURLTextView.text = sModel.eventURL
    publicKeyTextView.text = sModel.publishableKey
  }

  @IBAction func changeToNew(_: UIButton) { changeServerConfigToNew() }

  @IBAction func changeDeviceNameToNew(_: UIButton) {
    changeDevice(name: deviceNameTextfield.text)
  }

  private func updateText() {
    let SDKConfig = configurator.getHyperTrackConfig()
    DispatchQueue.main.async { [weak self] in
      guard let self = self else { return }
      self.hostURLTextView.text = SDKConfig.network.host
    }
  }

  private func changeDevice(name: String?) {
    activityIndicator(startAnimating: true)
    configurator.changeDevice(name: name) { [weak self] message in
      guard let self = self else { return }
      self.activityIndicator(startAnimating: false)
      self.showAlert(message: message)
    }
  }

  private func changeServerConfigToNew() {
    activityIndicator(startAnimating: true)
    configurator.changeBaseURLs(
      hostURL: hostURLTextView.text,
      publicKey: publicKeyTextView.text
    ) { [weak self] message in guard let self = self else { return }
      self.activityIndicator(startAnimating: false)
      self.showAlert(message: message)
    }
  }

  private func showAlert(message: String) {
    DispatchQueue.main.async { [weak self] in
      let alert = UIAlertController(
        title: "Attention",
        message: message,
        preferredStyle: .alert
      )
      alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
      self?.present(alert, animated: true, completion: nil)
    }
  }

  private func activityIndicator(startAnimating: Bool) {
    if startAnimating {
      DispatchQueue.main.async { [weak self] in
        self?.view.isUserInteractionEnabled = false
        self?.activityIndicator.startAnimating()
      }
    } else {
      DispatchQueue.main.async { [weak self] in
        self?.view.isUserInteractionEnabled = true
        self?.activityIndicator.stopAnimating()
      }
    }
  }

  @objc private func hyperTrackDidEncounterError(notification: Notification) {
    showAlert(
      message: "\(String(describing: notification.hyperTrackTrackingError()))"
    )
  }

  deinit { NotificationCenter.default.removeObserver(self) }
}

extension ChangeBaseURLViewController {
  func hideKeyboardWhenTappedAround() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(ChangeBaseURLViewController.dismissKeyboard)
    )
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc func dismissKeyboard() { view.endEditing(true) }
}

extension ChangeBaseURLViewController: UITextViewDelegate {
  func textView(
    _ textView: UITextView,
    shouldChangeTextIn _: NSRange,
    replacementText text: String
  ) -> Bool {
    if text == "\n" { textView.resignFirstResponder() }
    return true
  }
}

extension ChangeBaseURLViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    textField.resignFirstResponder()
    return true
  }
}
