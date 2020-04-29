import CoreLocation
import MapKit
import RxCocoa
import RxSwift
import UIKit

class DisplayTripViewController: UIViewController, BindableType {
  var viewModel: DisplayTripViewModel!
  private let disposeBag = DisposeBag()
  private let map = MKMapView()
  private var defaultEdge = UIEdgeInsets()
  private let manager = CLLocationManager()
  private let tripInfoContainer = UIView()
  private var сompleteTrip = UIButton()
  private var btShareTrip = UIBarButtonItem(
    barButtonSystemItem: .action,
    target: nil,
    action: nil
  )
  private let etaLabel = UILabel()
  override func viewDidLoad() {
    super.viewDidLoad()
    assemble()
  }

  private func assemble() {
    map.showsUserLocation = true
    map.tintColor = .green
    navigationItem.rightBarButtonItem = btShareTrip
    defaultEdge = UIEdgeInsets(top: 50.0, left: 10.0, bottom: 80.0, right: 10.0)
    tripInfoContainer.backgroundColor = .white
    сompleteTrip.setTitle("Complete trip", for: .normal)
    сompleteTrip.setTitleColor(.green, for: .normal)
    сompleteTrip.setTitleColor(.gray, for: .highlighted)
    /// Setup CLLocationManager
    manager.requestWhenInUseAuthorization()
    manager.startUpdatingLocation()
    setupLayout()
  }

  private func setupLayout() {
    view.addSubview(map)
    view.addSubview(tripInfoContainer)
    tripInfoContainer.addSubview(сompleteTrip)
    tripInfoContainer.addSubview(etaLabel)
    map.translatesAutoresizingMaskIntoConstraints = false
    etaLabel.translatesAutoresizingMaskIntoConstraints = false
    сompleteTrip.translatesAutoresizingMaskIntoConstraints = false
    tripInfoContainer.translatesAutoresizingMaskIntoConstraints = false
    map.snp.makeConstraints { make in make.top.equalTo(view.snp.top)
      make.left.equalTo(view.snp.left)
      make.right.equalTo(view.snp.right)
      make.bottom.equalTo(tripInfoContainer.snp.top)
    }
    tripInfoContainer.snp.makeConstraints { make in
      make.bottom.equalTo(view.snp.bottomMargin)
      make.left.equalTo(view.snp.left)
      make.right.equalTo(view.snp.right)
      make.height.equalTo(86)
    }
    сompleteTrip.snp.makeConstraints { make in
      make.top.equalTo(tripInfoContainer.snp.top).offset(18)
      make.right.equalTo(tripInfoContainer.snp.right).offset(-18)
      make.height.equalTo(50)
    }
    etaLabel.snp.makeConstraints { make in
      make.top.equalTo(tripInfoContainer.snp.top).offset(18)
      make.left.equalTo(tripInfoContainer.snp.left).offset(18)
      make.height.equalTo(50)
    }
  }

  func bindViewModel() {
    etaLabel.text = viewModel.getETA()
    btShareTrip.rx.tap.asDriver().drive(onNext: { [weak self] _ in
      guard let self = self else { return }
      self.viewModel.onOpenShareActionSteet()
    }).disposed(by: disposeBag)
    viewModel.requestProcessing.asDriver().drive(onNext: { [weak self] state in
      guard let self = self else { return }
      self.onDisplayActivityView(state: state)
    }).disposed(by: disposeBag)
    сompleteTrip.rx.tap.asDriver().drive(onNext: { [weak self] _ in
      guard let self = self else { return }
      self.viewModel.onEndTrip()
    }).disposed(by: disposeBag)
    manager.rx.didUpdateLocations.map { $1.first?.coordinate }
      .unwrappedOptional().subscribe(onNext: { [weak self] location in
        guard let self = self else { return }
        self.viewModel.configureDisplayTrip(location)
        self.manager.stopUpdatingLocation()
      }).disposed(by: disposeBag)
    let polylineObserver = Observable.combineLatest(
      viewModel.polyline,
      viewModel.defaultRect
    ) { ($0, $1) }
    polylineObserver.bind { [weak self] polyline, rect in
      guard let self = self, let p = polyline, let r = rect else { return }
      self.map.addOverlay(p)
      self.map.setVisibleMapRect(
        r,
        edgePadding: self.defaultEdge,
        animated: true
      )
    }.disposed(by: disposeBag)
    map.rx.handleRendererForOverlay { _, overlay -> (MKOverlayRenderer) in
      if overlay is MKPolyline {
        let polyLineRenderer = MKPolylineRenderer(overlay: overlay)
        polyLineRenderer.strokeColor = UIColor.green
        return polyLineRenderer
      } else { return MKOverlayRenderer() }
    }
  }
}

extension DisplayTripViewController {
  private func onDisplayActivityView(state: Bool) {
    if state { ActivityIndicatorView.startAnimatingOnView() } else {
      ActivityIndicatorView.stopAnimationOnView()
    }
  }
}
