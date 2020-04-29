import CoreLocation
import Foundation
import RxCocoa
import RxSwift

struct MapViewModel {
  let resultCoordinate: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(
    value: CLLocationCoordinate2D(latitude: 0, longitude: 0)
  )
}
