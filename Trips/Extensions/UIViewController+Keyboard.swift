import Foundation

extension UIViewController {
  func hideKeyboardWhenTapped() {
    let tap: UITapGestureRecognizer = UITapGestureRecognizer(
      target: self,
      action: #selector(UIViewController.hideKeyboard)
    )
    tap.cancelsTouchesInView = false
    view.addGestureRecognizer(tap)
  }

  @objc private func hideKeyboard() { view.endEditing(true) }
}
