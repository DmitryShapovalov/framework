import Foundation
import MapKit
import RxCocoa
import RxSwift

struct SearchViewModel {
  let items: BehaviorRelay<[MKLocalSearchCompletion]> = BehaviorRelay(value: [])
  let searchString: BehaviorRelay<String> = BehaviorRelay(value: "")
  let resultString: BehaviorRelay<String> = BehaviorRelay(value: "")
  let resultCoordinate: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(
    value: CLLocationCoordinate2D(latitude: 0, longitude: 0)
  )

  func mapItems(for searchRequest: MKLocalSearch) -> Observable<[MKMapItem]> {
    return Observable.create { observer in
      searchRequest.start(
        completionHandler: { response, _ in
          let items = response?.mapItems ?? []
          observer.onNext(items)
          observer.onCompleted()
        }
      )
      return Disposables.create { searchRequest.cancel() }
    }
  }
}
