import CoreLocation
import Foundation
import RxCocoa
import RxSwift
import UIKit

struct EditTripViewModel {
  let sceneCoordinator: SceneCoordinatorType
  let apiClient: APIClientType
  let disposeBag = DisposeBag()

  let dateObservable: BehaviorRelay<Date> = BehaviorRelay(value: Date())
  let timeObservable: BehaviorRelay<Date> = BehaviorRelay(value: Date())
  let coordinates: BehaviorRelay<CLLocationCoordinate2D> = BehaviorRelay(
    value: CLLocationCoordinate2D(latitude: 0, longitude: 0)
  )
  let radius: BehaviorRelay<Int> = BehaviorRelay(value: 30)
  let scheduled_at: BehaviorRelay<String> = BehaviorRelay(value: "")
  let metadata: BehaviorRelay<String> = BehaviorRelay(value: "")
  let requestProcessing: BehaviorRelay<Bool> = BehaviorRelay(value: false)
  init(apiClient: APIClientType, coordinator: SceneCoordinatorType) {
    self.apiClient = apiClient
    sceneCoordinator = coordinator
  }

  func onCreateTrip() {
    let date = DateFormatter.iso8601Full.date(from: scheduled_at.value)
    guard let datetime = date, datetime >= Date() else {
      sceneCoordinator.transition(
        to: .getAlert("Validation error", "Datetime cannot be in the past"),
        type: .modal
      )
      return
    }
    guard coordinates.value.latitude != 0, coordinates.value.longitude != 0
      else {
        sceneCoordinator.transition(
          to: .getAlert("REQUEST ERROR", "Empty coordinate"),
          type: .modal
        )
        return
    }
    if !metadata.value.isEmpty,
      let data = metadata.value.data(using: .utf8) {
      do {
        _ = try JSONSerialization.jsonObject(
          with: data,
          options: .allowFragments
        ) as? [String: String]
      } catch {
        sceneCoordinator.transition(
          to: .getAlert("error", "invalid metadata"),
          type: .modal
        )
        return
      }
    }
    requestProcessing.accept(true)
    let model = prepareForCreatingTrip(
      coord: coordinates.value,
      radius: radius.value,
      scheduled_at: scheduled_at.value,
      metadata: metadata.value
    )
    apiClient.createTrip(payload: model).map { $0.data.createTrip }.observeOn(
      MainScheduler.instance
    ).subscribe(
      onNext: { _ in self.requestProcessing.accept(false)
        self.sceneCoordinator.pop(animated: true)
      },
      onError: { error in self.requestProcessing.accept(false)
        self.sceneCoordinator.transition(
          to: .getAlert("REQUEST ERROR", error.localizedDescription),
          type: .modal
        )
      }
    ).disposed(by: disposeBag)
  }

  func onOpenMap() {
    let mapViewModel = MapViewModel()
    mapViewModel.resultCoordinate.bind(to: coordinates).disposed(by: disposeBag)
    sceneCoordinator.transition(to: Scene.openMap(mapViewModel), type: .push)
  }
}
