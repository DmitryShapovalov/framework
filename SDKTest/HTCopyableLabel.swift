import UIKit

class HTCopyableLabel: UILabel {
  var copyableText: String = ""

  public override var canBecomeFirstResponder: Bool { return true }

  override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  func commonInit() {
    isUserInteractionEnabled = true
    addGestureRecognizer(
      UILongPressGestureRecognizer(
        target: self,
        action: #selector(showMenu(sender:))
      )
    )
  }

  override func copy(_: Any?) {
    UIPasteboard.general.string = copyableText
    UIMenuController.shared.setMenuVisible(false, animated: true)
  }

  @objc func showMenu(sender _: Any?) {
    becomeFirstResponder()
    let menu = UIMenuController.shared
    if !menu.isMenuVisible {
      menu.setTargetRect(bounds, in: self)
      menu.setMenuVisible(true, animated: true)
    }
  }

  override func canPerformAction(_ action: Selector, withSender _: Any?) -> Bool
  { return (action == #selector(copy(_:))) }
}
