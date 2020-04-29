import Foundation
import RxCocoa
import RxSwift
import UIKit

struct TripListViewModel {
  let sceneCoordinator: SceneCoordinatorType
  let apiClient: APIClientType
  let disposeBag = DisposeBag()
  let tripList: BehaviorRelay<[TripModel]> = BehaviorRelay(value: [])
  init(apiClient: APIClientType, coordinator: SceneCoordinatorType) {
    self.apiClient = apiClient
    sceneCoordinator = coordinator
  }

  func onCreateTrip() {
    let editViewModel = EditTripViewModel(
      apiClient: apiClient,
      coordinator: sceneCoordinator
    )
    sceneCoordinator.transition(
      to: Scene.createTrip(editViewModel),
      type: .push
    )
  }

  func onDisplayTrip(trip: TripModel) {
    let editViewModel = DisplayTripViewModel(
      tripModel: trip,
      apiClient: apiClient,
      coordinator: sceneCoordinator
    )
    sceneCoordinator.transition(
      to: Scene.displayTrip(editViewModel),
      type: .push
    )
  }

  func fetchTrips() {
    apiClient.getUserTrips().map { $0.data.getMovementStatus.trips }.observeOn(
      MainScheduler.instance
    ).subscribe(
      onNext: { response in self.tripList.accept(response) },
      onError: { error in
        self.sceneCoordinator.transition(
          to: .getAlert("REQUEST ERROR", error.localizedDescription),
          type: .modal
        )
      }
    ).disposed(by: disposeBag)
  }
}
