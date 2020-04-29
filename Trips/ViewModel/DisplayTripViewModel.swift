import CoreLocation
import MapKit
import RxCocoa
import RxSwift
import UIKit

struct DisplayTripViewModel {
  let sceneCoordinator: SceneCoordinatorType
  let apiClient: APIClientType
  let disposeBag = DisposeBag()
  private let tripModel: TripModel!
  let polyline: BehaviorRelay<MKPolyline?> = BehaviorRelay(value: nil)
  let defaultRect: BehaviorRelay<MKMapRect?> = BehaviorRelay(value: nil)
  let requestProcessing: BehaviorRelay<Bool> = BehaviorRelay(value: false)
  init(
    tripModel: TripModel,
    apiClient: APIClientType,
    coordinator: SceneCoordinatorType
  ) {
    self.tripModel = tripModel
    self.apiClient = apiClient
    sceneCoordinator = coordinator
  }

  func configureDisplayTrip(_ userLocation: CLLocationCoordinate2D) {
    if let tripCoordinates = tripModel.estimate?.route?.polyline?.coordinates {
      let coordinates = mapCoordinate(coordinates: tripCoordinates)
      polyline.accept(coordinates)
      defaultRect.accept(coordinates.boundingMapRect)
    } else if let destinationCoordinate = tripModel.destination?.geometry?
      .coordinates {
      let coordinate = MKPolyline(
        coordinates: [
          CLLocationCoordinate2D(
            latitude: CLLocationDegrees(destinationCoordinate[1]),
            longitude: CLLocationDegrees(destinationCoordinate[0])
          )
        ],
        count: 1
      )
      polyline.accept(coordinate)
      defaultRect.accept(
        MKMapRect.makeRect(coordinates: [userLocation, coordinate.coordinate])
      )
    }
  }

  private func mapCoordinate(coordinates: [[Float]]) -> MKPolyline {
    var mappedCoordinate: [CLLocationCoordinate2D] = []
    for line in coordinates {
      mappedCoordinate.append(
        CLLocationCoordinate2D(
          latitude: CLLocationDegrees(line[1]),
          longitude: CLLocationDegrees(line[0])
        )
      )
    }
    return MKPolyline(
      coordinates: mappedCoordinate,
      count: mappedCoordinate.count
    )
  }

  func onOpenShareActionSteet() {
    if let shareLink = tripModel.views?.share_url,
      let embedLink = tripModel.views?.embed_url {
      sceneCoordinator.transition(
        to: Scene.openURLShareList(
          shareLink,
          embedLink,
          { url in
            self.sceneCoordinator.transition(
              to: Scene.shareTrip(url),
              type: .modal
            )
          }
        ),
        type: .modal
      )
    } else if let shareLink = tripModel.views?.share_url {
      sceneCoordinator.transition(to: Scene.shareTrip(shareLink), type: .modal)
    } else if let embedLink = tripModel.views?.embed_url {
      sceneCoordinator.transition(to: Scene.shareTrip(embedLink), type: .modal)
    } else {
      sceneCoordinator.transition(
        to: Scene.getAlert("Error", "views link not found"),
        type: .modal
      )
    }
  }

  func onEndTrip() {
    requestProcessing.accept(true)
    apiClient.endTrip(payload: tripModel).observeOn(MainScheduler.instance)
      .subscribe(
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

  func getETA() -> String {
    if let arrive_at = tripModel.estimate?.arrive_at {
      return
        "ETA: \(DateFormatter.convertStringDateToLocalTime(time: arrive_at))"
    } else { return "" }
  }
}
