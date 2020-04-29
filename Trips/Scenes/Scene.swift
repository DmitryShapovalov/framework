import Foundation

enum Scene {
  case tripsList(TripListViewModel)
  case createTrip(EditTripViewModel)
  case openMap(MapViewModel)
  case getAlert(String, String)
  case displayTrip(DisplayTripViewModel)
  case shareTrip(String)
  case openURLShareList(String, String, (String) -> Void)
}
