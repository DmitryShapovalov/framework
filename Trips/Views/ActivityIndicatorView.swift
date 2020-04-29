import UIKit

@IBDesignable class ActivityIndicatorView: UIView {
  private enum ViewTag: Int { case activityIndicatorTag = 33 }
  private let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
  override func prepareForInterfaceBuilder() { setupDefaultStyle() }
  override func awakeFromNib() {
    super.awakeFromNib()
    setupDefaultStyle()
    tag = ViewTag.activityIndicatorTag.rawValue
    activityIndicator.startAnimating()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    isHidden = true
    tag = ViewTag.activityIndicatorTag.rawValue
    setupDefaultStyle()
  }

  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupDefaultStyle()
    tag = ViewTag.activityIndicatorTag.rawValue
  }

  private func setupDefaultStyle() {
    setupDarkBackgrdoun()
    setupPurpleActivityIndicatorStyle()
    setActivityIndicatorPositionOnView()
  }

  private func setupDarkBackgrdoun() {
    backgroundColor = #colorLiteral(
      red: 0.02352941176,
      green: 0.02352941176,
      blue: 0.03529411765,
      alpha: 0.85
    )
  }

  private func setupPurpleActivityIndicatorStyle() {
    activityIndicator.color = #colorLiteral(
      red: 0,
      green: 0.8078431373,
      blue: 0.3568627451,
      alpha: 1
    )
  }

  private func setActivityIndicatorPositionOnView() {
    layoutIfNeeded()
    activityIndicator.center = center
    addSubview(activityIndicator)
  }

  class func startAnimatingOnView(endEditing _: Bool = true) {
    let window = UIApplication.shared.keyWindow!
    window.endEditing(true)
    let activityIndicatorView = ActivityIndicatorView(frame: window.frame)
    window.addSubview(activityIndicatorView)
    activityIndicatorView.startAnimating()
  }

  class func stopAnimationOnView() {
    let window = UIApplication.shared.keyWindow!
    if window.viewWithTag(ViewTag.activityIndicatorTag.rawValue)
      is ActivityIndicatorView {
      let aiView = window.viewWithTag(ViewTag.activityIndicatorTag.rawValue)
        as! ActivityIndicatorView
      aiView.stopAnimating()
    }
  }

  private func startAnimating() {
    alpha = 0
    isHidden = false
    UIView.animate(withDuration: 0.25, animations: { self.alpha = 1 }) { _ in
      self.activityIndicator.startAnimating()
    }
  }

  private func stopAnimating() {
    activityIndicator.stopAnimating()
    UIView.animate(withDuration: 0.25, animations: { self.alpha = 0 }) { _ in
      if self.tag == 33 { self.removeFromSuperview() } else {
        self.isHidden = true
      }
    }
  }
}
