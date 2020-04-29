import MapKit
import RxCocoa
import RxCoreLocation
import RxSwift
import UIKit

class MapViewController: UIViewController, BindableType {
  deinit { print("MapViewController") }
  var viewModel: MapViewModel!
  private let disposeBag = DisposeBag()
  private let map = MKMapView()
  private let manager = CLLocationManager()
  private let addPinGesture = UITapGestureRecognizer()
  private var annotation: MKPointAnnotation = MKPointAnnotation()

  override func viewDidLoad() {
    super.viewDidLoad()
    assemble()
  }

  private func assemble() {
    title = "Map"
    /// Setup CLLocationManager
    manager.requestWhenInUseAuthorization()
    manager.startUpdatingLocation()
    map.showsUserLocation = true
    map.tintColor = .green
    map.addGestureRecognizer(addPinGesture)
    setupLayout()
  }

  private func setupLayout() {
    view.addSubview(map)
    map.translatesAutoresizingMaskIntoConstraints = false
    map.snp.makeConstraints { make in make.top.equalTo(view.snp.top)
      make.left.equalTo(view.snp.left)
      make.right.equalTo(view.snp.right)
      make.bottom.equalTo(view.snp.bottom)
    }
  }

  func bindViewModel() {
    manager.rx.didUpdateLocations.map { $1.first }.unwrappedOptional()
      .subscribe(
        onNext: { [weak self] location in
          guard let self = self else { return }
          self.map.setRegion(
            MKCoordinateRegion(
              center: location.coordinate,
              latitudinalMeters: 400,
              longitudinalMeters: 400
            ),
            animated: true
          )
          self.manager.stopUpdatingLocation()
        }
      ).disposed(by: disposeBag)
    addPinGesture.rx.event.map { [weak self] recognizer in
      guard let self = self else {
        return CLLocationCoordinate2D(latitude: 0, longitude: 0)
      }
      let touchPoint = recognizer.location(in: self.map)
      return self.map.convert(touchPoint, toCoordinateFrom: self.map)
    }.bind(to: viewModel.resultCoordinate).disposed(by: disposeBag)
    viewModel.resultCoordinate.skip(1).bind(onNext: { [weak self] coordinate in
      guard let self = self else { return }
      self.map.removeAnnotation(self.annotation)
      self.annotation = MKPointAnnotation()
      self.annotation.coordinate = coordinate
      self.map.addAnnotation(self.annotation)
    }).disposed(by: disposeBag)
  }
}
